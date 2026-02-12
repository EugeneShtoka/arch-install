#!/bin/zsh

source /home/eugene/.env

echo "`date` enabling laptop monitor $MONITOR_LAPTOP"
xrandr --output $MONITOR_LAPTOP --auto

echo "`date` disconnecting monitor $MONITOR_EXTERNAL"
xrandr --output $MONITOR_EXTERNAL --off