package main

import (
	"fmt"
	"os"
	"os/exec"
	"time"
)

var gnomeStopped bool

// lockScreen attempts to lock the screen using multiple methods
func lockScreen() error {
	lockMethods := []string{
		"gnome-screensaver-command",
		"dm-tool",
		"loginctl",
	}

	// Try gnome-screensaver-command
	cmd := exec.Command("gnome-screensaver-command", "-l")
	if err := cmd.Run(); err == nil {
		return nil
	}

	// Try dm-tool lock
	cmd = exec.Command("dm-tool", "lock")
	if err := cmd.Run(); err == nil {
		return nil
	}

	// Try loginctl lock-session
	cmd = exec.Command("loginctl", "lock-session")
	if err := cmd.Run(); err == nil {
		return nil
	}

	return fmt.Errorf("all lock methods failed")
}

// stopGNOME stops the GNOME Display Manager
func stopGNOME() error {
	// Lock screen first
	if err := lockScreen(); err != nil {
		fmt.Fprintf(os.Stderr, "Warning: Could not lock screen: %v\n", err)
	}

	time.Sleep(1 * time.Second)

	// Try stopping gdm3
	cmd := exec.Command("sudo", "systemctl", "stop", "gdm3")
	if err := cmd.Run(); err == nil {
		return nil
	}

	// Try stopping gdm
	cmd = exec.Command("sudo", "systemctl", "stop", "gdm")
	if err := cmd.Run(); err == nil {
		return nil
	}

	return fmt.Errorf("could not stop GDM")
}

// startGNOME starts the GNOME Display Manager
func startGNOME() error {
	// Try starting gdm3
	cmd := exec.Command("sudo", "systemctl", "start", "gdm3")
	if err := cmd.Run(); err == nil {
		return nil
	}

	// Try starting gdm
	cmd = exec.Command("sudo", "systemctl", "start", "gdm")
	if err := cmd.Run(); err == nil {
		return nil
	}

	return fmt.Errorf("could not start GDM")
}

// getLidState checks the lid state via D-Bus
func getLidState() (bool, error) {
	cmd := exec.Command("dbus-send", "--system", "--print-reply",
		"--dest=org.freedesktop.login1",
		"/org/freedesktop/login1",
		"org.freedesktop.DBus.Properties.Get",
		"string:org.freedesktop.login1.Manager",
		"string:LidClosed")

	output, err := cmd.Output()
	if err != nil {
		return false, err
	}

	// Parse output to find "true" or "false"
	outputStr := string(output)
	if len(outputStr) > 0 {
		// Look for boolean value in output
		for i := 0; i < len(outputStr)-4; i++ {
			if i+4 <= len(outputStr) && outputStr[i:i+4] == "true" {
				return true, nil
			}
			if i+5 <= len(outputStr) && outputStr[i:i+5] == "false" {
				return false, nil
			}
		}
	}

	return false, fmt.Errorf("could not parse lid state")
}

func main() {
	fmt.Println("Starting lid lock daemon with GNOME stop/start...")
	
	prevState := false
	checkInterval := 1 * time.Second

	for {
		currentState, err := getLidState()
		if err != nil {
			fmt.Fprintf(os.Stderr, "Error checking lid state: %v\n", err)
			time.Sleep(checkInterval)
			continue
		}

		// Lid closed: lock screen and stop GNOME
		if currentState && !prevState {
			if !gnomeStopped {
				fmt.Printf("%s: Lid closed - locking screen and stopping GNOME\n", time.Now().Format(time.RFC3339))
				if err := stopGNOME(); err != nil {
					fmt.Fprintf(os.Stderr, "Error stopping GNOME: %v\n", err)
				} else {
					gnomeStopped = true
					fmt.Println("GNOME stopped successfully")
				}
			}
		}

		// Lid opened: start GNOME
		if !currentState && prevState {
			if gnomeStopped {
				fmt.Printf("%s: Lid opened - starting GNOME\n", time.Now().Format(time.RFC3339))
				if err := startGNOME(); err != nil {
					fmt.Fprintf(os.Stderr, "Error starting GNOME: %v\n", err)
				} else {
					gnomeStopped = false
					fmt.Println("GNOME started successfully")
				}
			}
		}

		prevState = currentState
		time.Sleep(checkInterval)
	}
}
