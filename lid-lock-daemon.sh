#!/bin/bash
# Monitor lid state and lock screen when closed

lock_screen() {
    /usr/bin/gnome-screensaver-command -l 2>/dev/null || \
    /usr/bin/dm-tool lock 2>/dev/null || \
    loginctl lock-session 2>/dev/null || \
    dbus-send --type=method_call --dest=org.gnome.ScreenSaver /org/gnome/ScreenSaver org.gnome.ScreenSaver.Lock 2>/dev/null
}

PREV_STATE="false"

while true; do
    CURRENT_STATE=$(dbus-send --system --print-reply --dest=org.freedesktop.login1 /org/freedesktop/login1 org.freedesktop.DBus.Properties.Get string:org.freedesktop.login1.Manager string:LidClosed 2>/dev/null | grep -o "true\|false")
    
    if [ "$CURRENT_STATE" = "true" ] && [ "$PREV_STATE" = "false" ]; then
        lock_screen
    fi
    
    PREV_STATE="$CURRENT_STATE"
    sleep 1
done
