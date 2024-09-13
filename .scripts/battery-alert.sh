#!/bin/bash

source $SCRIPTS_PATH/battery.sh

threshold=105
get_battery_info

if [ $battery_level -le $threshold ] && [ "$charging" != "yes" ]; then
    notify-send -u critical "$(get_battery_status $battery_level $charging) Low battery" --icon " " -r 101029
else
    dunstctl close 101029
fi