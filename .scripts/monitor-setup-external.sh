#!/bin/zsh

source /home/eugene/.env

MONITOR_LAPTOP=eDP-1
MONITOR_EXTERNAL=$(xrandr | grep ' connected' | grep -v "^${MONITOR_LAPTOP} " | head -n 1 | awk '{print $1}')

if [[ -z "$MONITOR_EXTERNAL" ]]; then
    echo "`date` monitor-setup-external: no external monitor found" >> $LOG_PATH
    exit 0
fi

externalActive=$(xrandr --listactivemonitors | grep "$MONITOR_EXTERNAL")
laptopActive=$(xrandr --listactivemonitors | grep "$MONITOR_LAPTOP")
if [[ -n "$externalActive" && -n "$laptopActive" ]]; then
    echo "`date` external active, disabling laptop monitor $MONITOR_LAPTOP" >> $LOG_PATH
    xrandr --output $MONITOR_LAPTOP --off
elif [[ -z "$externalActive" ]]; then
    echo "`date` connecting monitor $MONITOR_EXTERNAL" >> $LOG_PATH
    xrandr --output $MONITOR_EXTERNAL --auto
    sleep 1
    echo "`date` disabling laptop monitor $MONITOR_LAPTOP" >> $LOG_PATH
    xrandr --output $MONITOR_LAPTOP --off
fi
