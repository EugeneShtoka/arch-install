#!/bin/zsh

source /home/eugene/.env

if [[ $MONITOR_SETUP != "SINGLE"]]; then
    MONITOR_SETUP="SINGLE"

    echo turning off monitors >> /home/eugene/monitors.log
    xrandr --output $MONITOR_WORK_2 --off
    xrandr --output $MONITOR_WORK_3 --off
fi