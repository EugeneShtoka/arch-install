#!/bin/zsh

source /home/eugene/.env

monitorsCount=$(xrandr --listactivemonitors | grep 'Monitors:' | awk '{print $2}')
if [[ "$monitorsCount" -eq 1 ]]; then
    echo "`date` connecting monitor $MONITOR_EXTERNAL" >> $LOG_PATH
    xrandr --output $MONITOR_EXTERNAL --auto
    sleep 1
    echo "`date` disabling laptop monitor $MONITOR_LAPTOP" >> $LOG_PATH
    xrandr --output $MONITOR_LAPTOP --off

    $SCRIPTS_PATH/workspaces-work-setup.sh
fi