#!/bin/zsh

source /home/eugene/.env

MONITOR_LAPTOP=${MONITOR_LAPTOP:-eDP-1}

echo "`date` enabling laptop monitor $MONITOR_LAPTOP" >> $LOG_PATH
xrandr --output $MONITOR_LAPTOP --auto

# Turn off all connected non-laptop monitors
for monitor in $(xrandr | grep ' connected' | grep -v "^${MONITOR_LAPTOP} " | awk '{print $1}'); do
    echo "`date` disconnecting monitor $monitor" >> $LOG_PATH
    xrandr --output $monitor --off
done