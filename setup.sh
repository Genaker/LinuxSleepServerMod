#!/bin/bash
# Setup script for Linux Sleep Server Mod - Lock Screen Without Suspend

set -e

echo "=========================================="
echo "Linux Sleep Server Mod - Setup"
echo "Lock Screen Without Suspend"
echo "=========================================="
echo ""

# Check if running as root for some operations
if [ "$EUID" -eq 0 ]; then 
   echo "Please run this script as a regular user, not as root"
   exit 1
fi

USER_HOME=$HOME
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Step 1: Configuring GNOME Power Settings..."
gsettings set org.gnome.settings-daemon.plugins.power lid-close-ac-action 'nothing'
gsettings set org.gnome.settings-daemon.plugins.power lid-close-battery-action 'nothing'
echo "✓ GNOME power settings configured"
echo ""

echo "Step 2: Installing daemon scripts..."
mkdir -p ~/.local/bin

# Copy scripts
cp "$SCRIPT_DIR/lid-lock-daemon.sh" ~/.local/bin/
chmod +x ~/.local/bin/lid-lock-daemon.sh

# Check if Go is available for Go version
if command -v go &> /dev/null; then
    echo "Go detected - building Go version..."
    cd "$SCRIPT_DIR"
    if [ -f "lid-lock-daemon.go" ]; then
        go build -o lid-lock-daemon lid-lock-daemon.go
        cp lid-lock-daemon ~/.local/bin/
        chmod +x ~/.local/bin/lid-lock-daemon
        echo "✓ Go version installed"
    fi
else
    echo "Go not found - using bash version only"
fi

echo "✓ Daemon scripts installed"
echo ""

echo "Step 3: Configuring autostart..."
mkdir -p ~/.config/autostart

# Create autostart file
AUTOSTART_FILE="$HOME/.config/autostart/lid-lock.desktop"
cat > "$AUTOSTART_FILE" << EOF
[Desktop Entry]
Type=Application
Name=Lid Lock Daemon
Comment=Lock screen when laptop lid is closed
Exec=$HOME/.local/bin/lid-lock-daemon.sh
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
EOF

echo "✓ Autostart configured"
echo ""

echo "Step 4: Starting daemon..."
# Kill any existing daemon
pkill -f lid-lock-daemon 2>/dev/null || true
sleep 1

# Start new daemon
nohup ~/.local/bin/lid-lock-daemon.sh > /dev/null 2>&1 &
echo "✓ Daemon started"
echo ""

echo "=========================================="
echo "Setup Complete!"
echo "=========================================="
echo ""
echo "The daemon is now running. When you close your laptop lid:"
echo "  ✓ Screen will lock"
echo "  ✓ System will continue running"
echo "  ✓ All services will stay active"
echo ""
echo "To verify it's running:"
echo "  ps aux | grep lid-lock-daemon"
echo ""
echo "To stop the daemon:"
echo "  pkill -f lid-lock-daemon"
echo ""
echo "To disable autostart:"
echo "  rm ~/.config/autostart/lid-lock.desktop"
echo ""
