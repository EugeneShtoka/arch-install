#!/bin/zsh

source /home/eugene/.env
source /home/eugene/monitor.env

if [ "$MONITOR_SETUP" != SINGLE ]; then
    echo MONITOR_SETUP=SINGLE > monitor.env

    xrandr --output $MONITOR_WORK_2 --off
    xrandr --output $MONITOR_WORK_3 --off
fi