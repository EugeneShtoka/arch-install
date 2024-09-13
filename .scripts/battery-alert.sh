#!/bin/bash

source $SCRIPTS_PATH/battery.sh

threshold=15
get_battery_info

if [ $battery_level -le $threshold ] && [ "$discharging" = "discharging" ]; then
    notify-send -u critical "$(get_battery_status $battery_level $discharging) Low battery" --icon " " -r 101029
#else
    #dunstctl close 101029
fi

echo $prev_battery_level $((battery_level / 20))
# Update environment variable with current level (divided by 20)
export prev_battery_level=$((battery_level / 20))
if [ $((battery_level / 20)) -lt $prev_battery_level ]; then
echo AAAAAAAAAAAa
    notify-send "$(get_battery_status $battery_level $discharging)" --icon " " -r 101033
fi