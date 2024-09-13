#!/bin/bash

source $SCRIPTS_PATH/battery.sh
source $SCRIPTS_PATH/beep.sh

threshold=15
get_battery_info

if [ $battery_level -le $threshold ] && [ "$discharging" = "discharging" ]; then
    notify-send -u critical "$(get_battery_status $battery_level $discharging) Low battery" --icon " " -r 101029
    beep 0.03 440
    beep 0.03 440
    beep 0.03 440
else
    dunstctl close 101029
fi

BATTERY_LEVEL_FILE="$HOME/.previous_battery_level"
if [ -f "$BATTERY_LEVEL_FILE" ]; then
    prev_battery_level=$(cat "$BATTERY_LEVEL_FILE")
else
    prev_battery_level=5
fi

if [ $((battery_level / 20)) -lt $prev_battery_level ]; then
    notify-send "$(get_battery_status $battery_level $discharging)" --icon " " -r 101033
    beep
fi

echo $((battery_level / 20)) > "$BATTERY_LEVEL_FILE"
