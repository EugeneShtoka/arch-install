#!/bin/zsh

USR_HOME=/home/eugene
SCRIPTS_PATH=$USR_HOME/.scripts

# Small delay to let the monitor be recognized by xrandr
sleep 5

# Determine if running as root (udev) or as user (i3 startup)
if [[ "$EUID" -eq 0 ]]; then
    user="$(who -u | grep -F '(:0)' | head -n 1 | awk '{print $1}')"
    if [[ -z "$user" ]]; then
        echo "`date` monitor-setup-hook: No active X session user found" >> $USR_HOME/.scripts.log
        exit 1
    fi
    # Hotplug: skip duplicate events and keep a layout chosen from the menu
    su "$user" -c "DISPLAY=:0 $SCRIPTS_PATH/monitor-setup.sh auto --if-changed" >> $USR_HOME/.scripts.log 2>&1
else
    # i3 startup: always apply, X may come up with any layout
    DISPLAY=${DISPLAY:-:0} $SCRIPTS_PATH/monitor-setup.sh auto >> $USR_HOME/.scripts.log 2>&1
fi
