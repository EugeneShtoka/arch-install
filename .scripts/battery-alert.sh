#!/bin/bash

# Set your desired low battery threshold (in percentage)
threshold=75

# Get battery status using upower
power_info="$(upower -i /org/freedesktop/UPower/devices/battery_BAT0)"
print $power_info
battery_level=$(echo $power_info | grep percentage | awk '{print $2}' | tr -d %)
state=$(power_info | grep state | awk '{print $2}')
echo $battery_level $state

if [ $battery_level -le $threshold ]; then
    # Send a notification using your chosen daemon
    notify-send -u critical "Low Battery - $battery_level%" --icon " " -r 101029
else
    notify-send -h 101029
fi