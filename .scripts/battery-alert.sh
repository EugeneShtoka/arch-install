#!/bin/bash

source $SCRIPTS_PATH/battery.sh

threshold=15
get_battery_info

if [ $battery_level -le $threshold ] && [ "$discharging" = "discharging" ]; then
    notify-send -u critical "$(get_battery_status $battery_level $discharging) Low battery" --icon " " -r 101029
else
    dunstctl close 101029
fi

if [ $((battery_level / 20)) -lt $prev_battery_level ]; then
    prev_battery_level=$((battery_level / 20))
    notify-send "$(get_battery_status $battery_level $discharging)" --icon " " -r 101033
fi

BATTERY_LEVEL_FILE="$HOME/.previous_battery_level"
if [ -f "$BATTERY_LEVEL_FILE" ]; then
    prev_battery_level=$(cat "$BATTERY_LEVEL_FILE")
else
    prev_battery_level=5
fi

# Compare first, then update
if [ $((battery_level / 20)) -lt $prev_battery_level ]; then
    echo AAAAAAAAAAAa
    notify-send "$(get_battery_status $battery_level $discharging)" --icon " " -r 101033
fi

# Write updated level to file
echo $((battery_level / 20)) > "$BATTERY_LEVEL_FILE"