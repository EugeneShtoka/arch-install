#!/bin/bash

source $SCRIPTS_PATH/battery.sh

threshold=105
get_battery_info

if [ $battery_level -le $threshold ] && [ "$state" != "charging" ]; then
    # Send a notification using your chosen daemon
    notify-send -u critical "Low Battery - $battery_level%" --icon " " -r 101029
else
    dunstctl close 101029
fi