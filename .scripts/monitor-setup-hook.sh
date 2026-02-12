#!/bin/zsh

USR_HOME=/home/eugene
SCRIPTS_PATH=$USR_HOME/.scripts
MONITOR_LAPTOP=eDP-1

user="$(who -u | grep -F '(:0)' | head -n 1 | awk '{print $1}')"

if [[ -z "$user" ]]; then
    echo "`date` monitor-setup-hook: No active X session user found" >> $USR_HOME/.scripts.log
    exit 1
fi

# Auto-detect: find any connected monitor that isn't the laptop display
MONITOR_EXTERNAL=$(su "$user" -c "DISPLAY=:0 xrandr" 2>/dev/null | grep ' connected' | grep -v "^${MONITOR_LAPTOP} " | head -n 1 | awk '{print $1}')

if [[ -n "$MONITOR_EXTERNAL" ]]; then
    mode="external"
else
    mode="laptop"
fi

echo "`date` monitor-setup-hook: detected mode=$mode external=$MONITOR_EXTERNAL" >> $USR_HOME/.scripts.log
su "$user" -c "DISPLAY=:0 MONITOR_EXTERNAL=$MONITOR_EXTERNAL MONITOR_LAPTOP=$MONITOR_LAPTOP $SCRIPTS_PATH/monitor-setup-$mode.sh" >> $USR_HOME/.scripts.log 2>&1

