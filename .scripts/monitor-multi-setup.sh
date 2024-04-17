#!/bin/zsh

source /home/eugene/.env

echo $MONITOR_SETUP
if [ "$MONITOR_SETUP" != MULTI ]; then
    echo "single monitor setup detected"
    export MONITOR_SETUP="MULTI"

    echo connecting monitor $MONITOR_WORK_2 >> /home/eugene/monitors.log
    xrandr --output $MONITOR_WORK_2 --auto --right-of $MONITOR_LAPTOP
    sleep 2
    echo connecting monitor $MONITOR_WORK_3 >> /home/eugene/monitors.log
    xrandr --output $MONITOR_WORK_3 --auto --right-of $MONITOR_WORK_2
fi

$SCRIPTS_PATH/workspaces-work-setup.sh

echo $MONITOR_SETUP