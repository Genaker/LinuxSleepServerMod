#!/bin/bash
# Setup script to configure sudo access for lid GUI control
# Run this script with: sudo bash setup-lid-gui-sudo.sh

echo "Setting up sudo access for GDM control..."
echo "$SUDO_USER ALL=(ALL) NOPASSWD: /bin/systemctl stop gdm3, /bin/systemctl start gdm3, /bin/systemctl stop gdm, /bin/systemctl start gdm" > /etc/sudoers.d/lid-gui-control
chmod 0440 /etc/sudoers.d/lid-gui-control
echo "Sudo configuration created. You can now use the lid-lock-stop-gnome.sh script."
