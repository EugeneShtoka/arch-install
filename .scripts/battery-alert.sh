#!/bin/bash

source $SCRIPTS_PATH/battery.sh

threshold=105
get_battery_info

if [ $battery_level -le $threshold ] && [ "$charge_state" != "charging" ]; then
    notify-send -u critical "$(get_battery_status $battery_level $charge_state) Low battery" --icon " " -r 101029
else
    dunstctl close 101029
fi