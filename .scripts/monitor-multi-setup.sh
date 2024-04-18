#!/bin/zsh

source /home/eugene/.env
source /home/eugene/monitor.env

if [ "$MONITOR_SETUP" != MULTI ]; then
    echo MONITOR_SETUP=MULTI > monitor.env

    echo connecting monitor $MONITOR_WORK_2 >> /home/eugene/monitors.log
    xrandr --output $MONITOR_WORK_2 --auto --right-of $MONITOR_LAPTOP
    sleep 2
    echo connecting monitor $MONITOR_WORK_3 >> /home/eugene/monitors.log
    xrandr --output $MONITOR_WORK_3 --auto --right-of $MONITOR_WORK_2
    
    $SCRIPTS_PATH/workspaces-work-setup.sh
fi