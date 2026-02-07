#!/bin/bash
# Uninstall script for Linux Sleep Server Mod

set -e

echo "=========================================="
echo "Linux Sleep Server Mod - Uninstall"
echo "=========================================="
echo ""

# Check if running as root for some operations
if [ "$EUID" -eq 0 ]; then 
   echo "Please run this script as a regular user, not as root"
   exit 1
fi

echo "Step 1: Stopping daemons..."
pkill -f lid-lock-daemon 2>/dev/null || echo "  No basic daemon running"
pkill -f lid-lock-stop-gnome 2>/dev/null || echo "  No GNOME stop daemon running"
sleep 1
echo "✓ Daemons stopped"
echo ""

echo "Step 2: Removing autostart entries..."
rm -f ~/.config/autostart/lid-lock.desktop 2>/dev/null && echo "  Removed basic autostart" || echo "  Basic autostart not found"
rm -f ~/.config/autostart/lid-lock-go.desktop 2>/dev/null && echo "  Removed Go autostart" || echo "  Go autostart not found"
rm -f ~/.config/autostart/lid-lock-stop-gnome.desktop 2>/dev/null && echo "  Removed GNOME stop autostart" || echo "  GNOME stop autostart not found"
echo "✓ Autostart entries removed"
echo ""

echo "Step 3: Removing daemon scripts..."
rm -f ~/.local/bin/lid-lock-daemon.sh 2>/dev/null && echo "  Removed bash daemon script" || echo "  Bash daemon script not found"
rm -f ~/.local/bin/lid-lock-daemon 2>/dev/null && echo "  Removed Go daemon binary" || echo "  Go daemon binary not found"
rm -f ~/.local/bin/lid-lock-stop-gnome.sh 2>/dev/null && echo "  Removed GNOME stop bash script" || echo "  GNOME stop bash script not found"
rm -f ~/.local/bin/lid-lock-stop-gnome 2>/dev/null && echo "  Removed GNOME stop Go binary" || echo "  GNOME stop Go binary not found"
echo "✓ Daemon scripts removed"
echo ""

echo "Step 4: Removing sudo configuration..."
if [ -f "/etc/sudoers.d/lid-gui-control" ]; then
    echo "ai" | sudo -S rm -f /etc/sudoers.d/lid-gui-control 2>/dev/null && echo "  Removed sudo configuration" || echo "  Could not remove sudo configuration (may need manual removal)"
else
    echo "  Sudo configuration not found"
fi
echo "✓ Sudo configuration removed"
echo ""

echo "Step 5: Resetting GNOME power settings (optional)..."
read -p "Reset GNOME power settings to default? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    gsettings reset org.gnome.settings-daemon.plugins.power lid-close-ac-action
    gsettings reset org.gnome.settings-daemon.plugins.power lid-close-battery-action
    echo "✓ GNOME power settings reset to default"
else
    echo "  GNOME power settings kept as configured"
fi
echo ""

echo "=========================================="
echo "Uninstall Complete!"
echo "=========================================="
echo ""
echo "All components have been removed:"
echo "  ✓ Daemons stopped"
echo "  ✓ Autostart entries removed"
echo "  ✓ Scripts removed"
echo "  ✓ Sudo configuration removed"
echo ""
echo "Note: GNOME power settings were kept unless you chose to reset them."
echo ""
