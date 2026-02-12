#!/bin/zsh

source /home/eugene/.env

echo "`date` enabling laptop monitor $MONITOR_LAPTOP"
xrandr --output $MONITOR_LAPTOP --auto

echo "`date` disconnecting monitor $MONITOR_WORK_2"
xrandr --output $MONITOR_WORK_2 --off