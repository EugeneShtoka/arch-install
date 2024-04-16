#!/bin/zsh

num_monitors=$(xrandr --listactivemonitors | grep -c 'Monitors:') 

if [[ $num_monitors -eq 1 ]]; then
    #$SCRIPTS_PATH/monitor-multi-setup.sh
    echo switch to multi monitor
else 
    #$SCRIPTS_PATH/monitor-single-setup.sh
    echo switch to single monitor
fi