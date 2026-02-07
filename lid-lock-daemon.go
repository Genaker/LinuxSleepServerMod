package main

import (
	"fmt"
	"os"
	"os/exec"
	"time"
)

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

	// Try dbus-send as fallback
	cmd = exec.Command("dbus-send", "--type=method_call",
		"--dest=org.gnome.ScreenSaver",
		"/org/gnome/ScreenSaver",
		"org.gnome.ScreenSaver.Lock")
	if err := cmd.Run(); err == nil {
		return nil
	}

	return fmt.Errorf("all lock methods failed")
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
			if outputStr[i:i+4] == "true" {
				return true, nil
			}
			if outputStr[i:i+5] == "false" {
				return false, nil
			}
		}
	}

	return false, fmt.Errorf("could not parse lid state")
}

func main() {
	fmt.Println("Starting lid lock daemon...")
	
	prevState := false
	checkInterval := 1 * time.Second

	for {
		currentState, err := getLidState()
		if err != nil {
			fmt.Fprintf(os.Stderr, "Error checking lid state: %v\n", err)
			time.Sleep(checkInterval)
			continue
		}

		// Detect transition from open to closed
		if currentState && !prevState {
			fmt.Println("Lid closed - locking screen...")
			if err := lockScreen(); err != nil {
				fmt.Fprintf(os.Stderr, "Error locking screen: %v\n", err)
			} else {
				fmt.Println("Screen locked successfully")
			}
		}

		prevState = currentState
		time.Sleep(checkInterval)
	}
}
