#!/bin/bash

# Set your desired low battery threshold (in percentage)
threshold=15

# Get battery status using upower
power_info="$(upower -i /org/freedesktop/UPower/devices/battery_BAT0)"
battery_level=$(echo "$power_info" | grep percentage | awk '{print $2}' | tr -d %)
state=$(echo "$power_info" | grep state | awk '{print $2}')
echo $battery_level $state

if (( $state="discharging" )); then
    printf "\uf1e6"
fi

if [ $battery_level -le $threshold ] && [ "$state" != "charging" ]; then
    # Send a notification using your chosen daemon
    notify-send -u critical "Low Battery - $battery_level%" --icon " " -r 101029
else
    dunstctl close 101029
fi