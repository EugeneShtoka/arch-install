#!/bin/bash

# Set your desired low battery threshold (in percentage)
threshold=15

# Get battery status using acpi
battery_level=$(acpi -b | grep -P -o '[0-9]+(?=%)')

if [ $battery_level -le $threshold ]; then
    # Send a notification using your chosen daemon
    notify-send -u critical "Low Battery" "Battery level is at $battery_level%. Please plug in your charger." 
fi