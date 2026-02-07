#!/bin/bash
# One-command installer for Linux Sleep Server Mod
# Downloads from GitHub and installs automatically
# Usage: install.sh [lock|gui-stop]
#   lock      - Lock screen only (default)
#   gui-stop  - Lock screen + Stop GUI

set -e

REPO_URL="https://github.com/Genaker/LinuxSleepServerMod"
INSTALL_DIR="/tmp/lockscreen-install-$$"

# Determine installation mode
MODE="${1:-lock}"

if [ "$MODE" != "lock" ] && [ "$MODE" != "gui-stop" ]; then
    echo "Invalid mode: $MODE"
    echo "Usage: $0 [lock|gui-stop]"
    echo "  lock      - Lock screen only (default)"
    echo "  gui-stop  - Lock screen + Stop GUI"
    exit 1
fi

echo "=========================================="
echo "Linux Sleep Server Mod - Quick Install"
if [ "$MODE" = "lock" ]; then
    echo "Mode: Lock Screen Only"
else
    echo "Mode: Lock Screen + Stop GUI"
fi
echo "=========================================="
echo ""

# Check if running as root
if [ "$EUID" -eq 0 ]; then 
   echo "Please run this script as a regular user, not as root"
   exit 1
fi

# Check for wget or curl
if command -v wget &> /dev/null; then
    DOWNLOAD_CMD="wget"
elif command -v curl &> /dev/null; then
    DOWNLOAD_CMD="curl"
else
    echo "Error: Neither wget nor curl is installed"
    echo "Please install one of them:"
    echo "  Ubuntu/Debian: sudo apt install wget"
    echo "  Fedora: sudo dnf install wget"
    exit 1
fi

# Create temporary directory
mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"

echo "Step 1: Downloading from GitHub..."
if [ "$DOWNLOAD_CMD" = "wget" ]; then
    wget "$REPO_URL/archive/refs/heads/main.zip" -O lockscreen.zip
else
    curl -L "$REPO_URL/archive/refs/heads/main.zip" -o lockscreen.zip
fi

echo "Step 2: Extracting..."
unzip -q lockscreen.zip
cd LinuxSleepServerMod-main

echo "Step 3: Running setup..."
if [ "$MODE" = "lock" ]; then
    chmod +x setup-lock.sh
    ./setup-lock.sh
else
    chmod +x setup-gui-stop.sh
    ./setup-gui-stop.sh
fi

echo ""
echo "Step 4: Cleaning up..."
cd /
rm -rf "$INSTALL_DIR"

echo ""
echo "=========================================="
echo "Installation Complete!"
echo "=========================================="
