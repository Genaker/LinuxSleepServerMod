#!/bin/bash
# Monitor lid state: lock screen AND stop GNOME GUI when closed, restart GUI when opened

lock_screen() {
    /usr/bin/gnome-screensaver-command -l 2>/dev/null || \
    /usr/bin/dm-tool lock 2>/dev/null || \
    loginctl lock-session 2>/dev/null || \
    dbus-send --type=method_call --dest=org.gnome.ScreenSaver /org/gnome/ScreenSaver org.gnome.ScreenSaver.Lock 2>/dev/null
}

stop_gnome() {
    # Lock screen first
    lock_screen
    sleep 1
    # Stop GDM (GNOME Display Manager) - this stops GNOME GUI
    sudo systemctl stop gdm3 2>/dev/null || sudo systemctl stop gdm 2>/dev/null
}

start_gnome() {
    # Start GDM (GNOME Display Manager) - shows login screen
    sudo systemctl start gdm3 2>/dev/null || sudo systemctl start gdm 2>/dev/null
}

PREV_STATE="false"
GNOME_STOPPED=false

while true; do
    # Check lid state via dbus (works even without GUI)
    CURRENT_STATE=$(dbus-send --system --print-reply --dest=org.freedesktop.login1 /org/freedesktop/login1 org.freedesktop.DBus.Properties.Get string:org.freedesktop.login1.Manager string:LidClosed 2>/dev/null | grep -o "true\|false")
    
    # Lid closed: lock screen AND stop GNOME
    if [ "$CURRENT_STATE" = "true" ] && [ "$PREV_STATE" = "false" ]; then
        if [ "$GNOME_STOPPED" = false ]; then
            echo "$(date): Lid closed - locking screen and stopping GNOME"
            stop_gnome
            GNOME_STOPPED=true
        fi
    fi
    
    # Lid opened: start GNOME (to show login screen)
    if [ "$CURRENT_STATE" = "false" ] && [ "$PREV_STATE" = "true" ]; then
        if [ "$GNOME_STOPPED" = true ]; then
            echo "$(date): Lid opened - starting GNOME"
            start_gnome
            GNOME_STOPPED=false
        fi
    fi
    
    PREV_STATE="$CURRENT_STATE"
    sleep 1
done
