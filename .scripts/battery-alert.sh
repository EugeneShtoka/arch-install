#!/bin/bash

source $HOME/.scripts/battery.sh
source $HOME/.scripts/beep.sh

threshold=15
get_battery_info

if [ $battery_level -le $threshold ] && [ "$battery_state" = "discharging" ]; then
    notify-send -u critical "$(get_battery_status $battery_level $battery_state) Low battery" --icon " " -r 101029
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

# Notify every 20% drop while discharging
current_level_step=$((battery_level / 20))
if [ $current_level_step -lt $prev_battery_level ] && [ "$battery_state" = "discharging" ]; then
    notify-send "Discharging $(get_battery_status $battery_level $battery_state)" --icon " " -r 101033
    beep
fi
echo $current_level_step > "$BATTERY_LEVEL_FILE"
