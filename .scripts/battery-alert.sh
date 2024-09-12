#!/bin/bash

source $SCRIPTS_PATH/battery.sh

threshold=105
get_battery_info

if [ $battery_level -le $threshold ] && [ "$state" != "charging" ]; then
    # Send a notification using your chosen daemon
    
    notify-send -u critical "$(get_batery_status $battery_level $charge_state) Low Battery" --icon " " -r 101029
else
    dunstctl close 101029
fi