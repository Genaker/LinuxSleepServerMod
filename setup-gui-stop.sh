#!/bin/bash
# Setup script for Linux Sleep Server Mod - Lock Screen and Stop GUI

set -e

echo "=========================================="
echo "Linux Sleep Server Mod - GUI Stop Setup"
echo "Lock Screen AND Stop GNOME GUI"
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

echo "Step 2: Setting up sudo access for GDM control..."
if [ ! -f "/etc/sudoers.d/lid-gui-control" ]; then
    USERNAME=$(whoami)
    echo "$USERNAME" | sudo -S bash -c "echo '$USERNAME ALL=(ALL) NOPASSWD: /bin/systemctl stop gdm3, /bin/systemctl start gdm3, /bin/systemctl stop gdm, /bin/systemctl start gdm' > /etc/sudoers.d/lid-gui-control"
    echo "$USERNAME" | sudo -S chmod 0440 /etc/sudoers.d/lid-gui-control
    echo "✓ Sudo configuration created"
else
    echo "✓ Sudo configuration already exists"
fi
echo ""

echo "Step 3: Installing daemon scripts..."
mkdir -p ~/.local/bin

# Copy bash script
cp "$SCRIPT_DIR/lid-lock-stop-gnome.sh" ~/.local/bin/
chmod +x ~/.local/bin/lid-lock-stop-gnome.sh

# Check if Go is available for Go version
if command -v go &> /dev/null; then
    echo "Go detected - building Go version..."
    cd "$SCRIPT_DIR"
    if [ -f "lid-lock-stop-gnome.go" ]; then
        go build -o lid-lock-stop-gnome lid-lock-stop-gnome.go
        cp lid-lock-stop-gnome ~/.local/bin/
        chmod +x ~/.local/bin/lid-lock-stop-gnome
        echo "✓ Go version installed"
    fi
else
    echo "Go not found - using bash version only"
fi

echo "✓ Daemon scripts installed"
echo ""

echo "Step 4: Configuring autostart..."
mkdir -p ~/.config/autostart

# Create autostart file for GNOME stop version
AUTOSTART_FILE="$HOME/.config/autostart/lid-lock-stop-gnome.desktop"
cat > "$AUTOSTART_FILE" << EOF
[Desktop Entry]
Type=Application
Name=Lid Lock & Stop GNOME
Comment=Lock screen and stop GNOME GUI when laptop lid is closed
Exec=$HOME/.local/bin/lid-lock-stop-gnome.sh
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
EOF

echo "✓ Autostart configured"
echo ""

echo "Step 5: Stopping any existing daemons..."
# Kill any existing daemon
pkill -f lid-lock-daemon 2>/dev/null || true
pkill -f lid-lock-stop-gnome 2>/dev/null || true
sleep 1

echo "Step 6: Starting daemon..."
# Start new daemon
nohup ~/.local/bin/lid-lock-stop-gnome.sh > /dev/null 2>&1 &
echo "✓ Daemon started"
echo ""

echo "=========================================="
echo "Setup Complete!"
echo "=========================================="
echo ""
echo "The daemon is now running. When you close your laptop lid:"
echo "  ✓ Screen will lock"
echo "  ✓ GNOME GUI will stop (logs you out)"
echo "  ✓ System will continue running"
echo "  ✓ All services will stay active"
echo ""
echo "When you open the lid:"
echo "  ✓ GNOME will start"
echo "  ✓ Login screen will appear"
echo ""
echo "To verify it's running:"
echo "  ps aux | grep lid-lock-stop-gnome"
echo ""
echo "To stop the daemon:"
echo "  pkill -f lid-lock-stop-gnome"
echo ""
echo "To disable autostart:"
echo "  rm ~/.config/autostart/lid-lock-stop-gnome.desktop"
echo ""
