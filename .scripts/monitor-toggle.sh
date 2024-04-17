#!/bin/zsh

source /home/eugene/.env
echo `date` monitor event catched $1 >> /home/eugene/monitors.log
echo $SCRIPTS_PATH >> /home/eugene/monitors.log

num_monitors=$(xrandr --listactivemonitors | grep 'Monitors:' | awk '{print $2}') 

if [[ $num_monitors -eq 1 ]]; then
    $SCRIPTS_PATH/monitor-multi-setup.sh
else 
    $SCRIPTS_PATH/monitor-single-setup.sh
fi