.PHONY: build build-all install clean

# Build all Go binaries
build-all: build-daemon build-stop-gnome

# Build basic lid lock daemon
build-daemon:
	go build -o lid-lock-daemon lid-lock-daemon.go

# Build advanced version with GNOME stop/start
build-stop-gnome:
	go build -o lid-lock-stop-gnome lid-lock-stop-gnome.go

# Install binaries to ~/.local/bin
install: build-all
	mkdir -p ~/.local/bin
	cp lid-lock-daemon ~/.local/bin/
	cp lid-lock-stop-gnome ~/.local/bin/
	chmod +x ~/.local/bin/lid-lock-daemon
	chmod +x ~/.local/bin/lid-lock-stop-gnome
	@echo "Binaries installed to ~/.local/bin/"

# Clean build artifacts
clean:
	rm -f lid-lock-daemon lid-lock-stop-gnome

# Run basic daemon (for testing)
run-daemon: build-daemon
	./lid-lock-daemon

# Run advanced daemon (for testing)
run-stop-gnome: build-stop-gnome
	./lid-lock-stop-gnome
