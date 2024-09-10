#!/bin/bash

# Set your desired low battery threshold (in percentage)
threshold=75

# Get battery status using acpi
battery_level=$(upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep percentage | awk '{print $2}' | tr -d %)

if [ $battery_level -le $threshold ]; then
    # Send a notification using your chosen daemon
    notify-send -u critical "Low Battery $battery_level%"
fi