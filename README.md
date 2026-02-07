# Linux Sleep Server Mod

Keep your Linux laptop running when you close the lid - lock the screen without suspending.

## Overview

This solution configures your Linux laptop (GNOME-based) to **lock the screen** when you close the lid, **without suspending** the system. All services, SSH connections, and background processes continue running.

Perfect for:
- 🖥️ Server laptops that need to stay accessible
- 💻 Development machines running services/containers
- 🌐 Remote workstations accessed via SSH
- 🎬 Media servers or home automation systems
- ⚙️ Long-running computations

## Quick Start

### Automated Setup (Recommended)

**Option 1: Lock Screen Only**
```bash
./setup-lock.sh
```

**Option 2: Lock Screen + Stop GUI**
```bash
./setup-gui-stop.sh
```

These scripts will:
- Configure GNOME power settings
- Install daemon scripts (bash and Go if available)
- Set up autostart
- Start the daemon

### Uninstall

To remove everything:
```bash
./uninstall.sh
```

### Manual Setup

#### Step 1: Configure GNOME Power Settings

```bash
gsettings set org.gnome.settings-daemon.plugins.power lid-close-ac-action 'nothing'
gsettings set org.gnome.settings-daemon.plugins.power lid-close-battery-action 'nothing'
```

#### Step 2: Install the Lock Daemon

**Option A: Using Bash Scripts**

```bash
# Create script directory
mkdir -p ~/.local/bin

# Copy the daemon script
cp lid-lock-daemon.sh ~/.local/bin/
chmod +x ~/.local/bin/lid-lock-daemon.sh
```

**Option B: Using Go (Recommended for better performance)**

```bash
# Install Go if not already installed
# Ubuntu/Debian: sudo apt install golang-go
# Fedora: sudo dnf install golang

# Build and install
make install

# Or manually:
go build -o lid-lock-daemon lid-lock-daemon.go
cp lid-lock-daemon ~/.local/bin/
chmod +x ~/.local/bin/lid-lock-daemon
```

#### Step 3: Configure Autostart

```bash
# Create autostart directory
mkdir -p ~/.config/autostart

# Copy autostart file (edit YOUR_USERNAME first)
cp lid-lock.desktop ~/.config/autostart/
# Edit ~/.config/autostart/lid-lock.desktop and replace YOUR_USERNAME with your username
```

#### Step 4: Start the Daemon

**Bash version:**
```bash
nohup ~/.local/bin/lid-lock-daemon.sh > /dev/null 2>&1 &
```

**Go version:**
```bash
nohup ~/.local/bin/lid-lock-daemon > /dev/null 2>&1 &
```

## What It Does

- ✅ **Locks screen** when lid closes (within 1 second)
- ✅ **System keeps running** - no suspend
- ✅ **All services active** - SSH, web servers, containers
- ✅ **Network stays connected** - remote access available
- ✅ **Background processes continue** - no interruptions

## Files Included

### Bash Scripts
- `lid-lock-daemon.sh` - Main daemon script that monitors lid state
- `lid-lock-stop-gnome.sh` - Advanced version that also stops GUI
- `setup-lid-gui-sudo.sh` - Helper script for sudo configuration
- `lid-lock.desktop` - Autostart configuration file

### Go Versions
- `lid-lock-daemon.go` - Go version of the main daemon
- `lid-lock-stop-gnome.go` - Go version with GNOME stop/start
- `go.mod` - Go module definition
- `Makefile` - Build and install automation

## Advanced: Stop GUI When Lid Closes

For maximum resource savings, use the version that also stops GNOME GUI:

### Setup Sudo Access

```bash
sudo bash setup-lid-gui-sudo.sh
```

### Use Enhanced Script

**Bash version:**
```bash
cp lid-lock-stop-gnome.sh ~/.local/bin/
chmod +x ~/.local/bin/lid-lock-stop-gnome.sh
# Update autostart file to use lid-lock-stop-gnome.sh instead
```

**Go version:**
```bash
go build -o lid-lock-stop-gnome lid-lock-stop-gnome.go
cp lid-lock-stop-gnome ~/.local/bin/
chmod +x ~/.local/bin/lid-lock-stop-gnome
# Update autostart file to use lid-lock-stop-gnome instead
```

**Behavior:**
- Lid closes → Locks screen → Stops GNOME → Logs out
- Lid opens → Starts GNOME → Shows login screen

## Verification

Check if daemon is running:
```bash
ps aux | grep lid-lock-daemon
```

Check lid state:
```bash
dbus-send --system --print-reply --dest=org.freedesktop.login1 /org/freedesktop/login1 org.freedesktop.DBus.Properties.Get string:org.freedesktop.login1.Manager string:LidClosed
```

## Customization

### Change Check Interval

**Bash scripts:**
Edit the script and modify `sleep 1`:
- `sleep 0.5` - Faster response (more CPU)
- `sleep 2` - Slower response (less CPU)

**Go versions:**
Edit the Go source and modify `checkInterval := 1 * time.Second`:
- `500 * time.Millisecond` - Faster response (more CPU)
- `2 * time.Second` - Slower response (less CPU)

### Stop Daemon

```bash
# Stop bash version
pkill -f lid-lock-daemon.sh

# Stop Go version
pkill -f lid-lock-daemon
```

### Disable Autostart

```bash
rm ~/.config/autostart/lid-lock.desktop
```

## Troubleshooting

### Screen Doesn't Lock

1. Check daemon is running: `ps aux | grep lid-lock-daemon`
2. Check permissions: `ls -l ~/.local/bin/lid-lock-daemon.sh`
3. Test lock manually: `gnome-screensaver-command -l`

### System Still Suspends

1. Verify settings: `gsettings get org.gnome.settings-daemon.plugins.power lid-close-ac-action`
2. Should return `'nothing'`

## How It Works

The daemon monitors lid state via D-Bus (`org.freedesktop.login1.Manager.LidClosed`) every second. When it detects lid closing, it locks the screen. GNOME power settings are configured to do `'nothing'` when lid closes, so the system never suspends.

### Bash vs Go Versions

Both versions provide the same functionality:
- **Bash versions**: Simple, no compilation needed, easy to modify
- **Go versions**: Better performance, single binary, easier to distribute

Choose based on your preference. The Go versions are recommended for production use due to better resource usage and performance.

## Requirements

- Linux with GNOME desktop environment
- systemd (most modern distributions)
- Tested on: Ubuntu 22.04+, Fedora, Debian with GNOME

**For Go versions:**
- Go 1.21 or later (for building from source)
- Or use pre-built binaries (if available)

## Security Notes

- Screen locks when lid closes
- System stays powered on - configure firewall properly
- SSH access remains - use key-based authentication
- Consider full disk encryption for additional security

## License

Free to use and modify as needed.

## Contributing

Feel free to submit issues or pull requests with improvements!

## Author

Created to solve the problem of keeping Linux laptops running while maintaining screen security.
