# Building and Installing

## Prerequisites

- Go 1.21 or later
- Make (optional, for using Makefile)

## Quick Build

### Using Makefile (Recommended)

```bash
# Build all binaries
make build-all

# Build and install to ~/.local/bin
make install

# Clean build artifacts
make clean

# Run for testing
make run-daemon
make run-stop-gnome
```

### Manual Build

```bash
# Build basic daemon
go build -o lid-lock-daemon lid-lock-daemon.go

# Build advanced version
go build -o lid-lock-stop-gnome lid-lock-stop-gnome.go

# Install manually
mkdir -p ~/.local/bin
cp lid-lock-daemon ~/.local/bin/
cp lid-lock-stop-gnome ~/.local/bin/
chmod +x ~/.local/bin/lid-lock-daemon
chmod +x ~/.local/bin/lid-lock-stop-gnome
```

## Cross-Compilation

Build for different architectures:

```bash
# Linux AMD64
GOOS=linux GOARCH=amd64 go build -o lid-lock-daemon-linux-amd64 lid-lock-daemon.go

# Linux ARM64
GOOS=linux GOARCH=arm64 go build -o lid-lock-daemon-linux-arm64 lid-lock-daemon.go

# Linux ARM (32-bit)
GOOS=linux GOARCH=arm go build -o lid-lock-daemon-linux-arm lid-lock-daemon.go
```

## Testing

Run the daemon in foreground to see output:

```bash
# Basic version
./lid-lock-daemon

# Advanced version (requires sudo setup)
./lid-lock-stop-gnome
```

Press Ctrl+C to stop.

## Installation as System Service

You can also install as a systemd user service:

```bash
# Create service file
cat > ~/.config/systemd/user/lid-lock.service << EOF
[Unit]
Description=Lid Lock Daemon
After=graphical-session.target

[Service]
Type=simple
ExecStart=%h/.local/bin/lid-lock-daemon
Restart=always
RestartSec=5

[Install]
WantedBy=default.target
EOF

# Enable and start
systemctl --user enable lid-lock.service
systemctl --user start lid-lock.service

# Check status
systemctl --user status lid-lock.service
```
