#!/bin/zsh

source /home/eugene/.env

monitorsCount=$(xrandr --listactivemonitors | grep 'Monitors:' | awk '{print $2}')
if [ "$monitorsCount" -gt 1 ]; then  
    echo "`date` disconnecting monitor $MONITOR_WORK_2"
    xrandr --output $MONITOR_WORK_2 --off

    echo "`date` disconnecting monitor $MONITOR_WORK_3"
    xrandr --output $MONITOR_WORK_3 --off
fi