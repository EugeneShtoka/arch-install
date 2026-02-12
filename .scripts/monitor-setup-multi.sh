#!/bin/zsh

source /home/eugene/.env

monitorsCount=$(xrandr --listactivemonitors | grep 'Monitors:' | awk '{print $2}')
if [[ "$monitorsCount" -eq 1 ]]; then
    echo "`date` connecting monitor $MONITOR_WORK_2" >> $LOG_PATH
    xrandr --output $MONITOR_WORK_2 --auto
    sleep 1
    echo "`date` connecting monitor $MONITOR_WORK_3" >> $LOG_PATH
    xrandr --output $MONITOR_WORK_3 --auto --right-of $MONITOR_WORK_2
    sleep 1
    echo "`date` disabling laptop monitor $MONITOR_LAPTOP" >> $LOG_PATH
    xrandr --output $MONITOR_LAPTOP --off

    $SCRIPTS_PATH/workspaces-work-setup.sh
fi