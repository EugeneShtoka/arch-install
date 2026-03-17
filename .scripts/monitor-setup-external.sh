#!/bin/zsh

source /home/eugene/.env

MONITOR_LAPTOP=eDP-1
MONITOR_EXTERNAL=$(xrandr | grep ' connected' | grep -v "^${MONITOR_LAPTOP} " | head -n 1 | awk '{print $1}')

if [[ -z "$MONITOR_EXTERNAL" ]]; then
    echo "`date` monitor-setup-external: no external monitor found" >> $LOG_PATH
    exit 0
fi

echo "`date` connecting monitor $MONITOR_EXTERNAL" >> $LOG_PATH
xrandr --output $MONITOR_EXTERNAL --auto --primary

lid_state=$(cat /proc/acpi/button/lid/LID0/state 2>/dev/null | awk '{print $2}')
if [[ "$lid_state" == "open" ]]; then
    echo "`date` lid open, placing $MONITOR_LAPTOP to the right of $MONITOR_EXTERNAL" >> $LOG_PATH
    xrandr --output $MONITOR_LAPTOP --auto --right-of $MONITOR_EXTERNAL
else
    echo "`date` lid closed, disabling $MONITOR_LAPTOP" >> $LOG_PATH
    xrandr --output $MONITOR_LAPTOP --off
fi
