#!/bin/zsh

echo connecting monitor $MONITOR_WORK_2
xrandr --output $MONITOR_WORK_2 --auto --right-of $MONITOR_LAPTOP
sleep 2
echo connecting monitor $MONITOR_WORK_3
xrandr --output $MONITOR_WORK_3 --auto --right-of $MONITOR_WORK_2

$SCRIPTS_PATH/workspaces-work-setup.sh