#!/bin/zsh

num_monitors=$(xrandr --listactivemonitors | grep 'Monitors:' | awk '{print $2}') 

if [[ $num_monitors -eq 1 ]]; then
    $SCRIPTS_PATH/monitor-multi-setup.sh
else 
    $SCRIPTS_PATH/monitor-single-setup.sh
fi