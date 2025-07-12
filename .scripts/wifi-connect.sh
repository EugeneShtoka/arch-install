#!/bin/bash

ROFI_PROMPT="Select Wi-Fi Network  "

NETWORKS=$(sudo iw dev wlan0 scan | awk '/SSID:/ {print $2}' | sort -u)

if [ -z "$NETWORKS" ]; then
    echo "No Wi-Fi networks found. Ensure the interface wlan0 is up and working."
    echo "Also, confirm that 'iwd.service' is running: 'systemctl status iwd.service'"
    exit 1
fi

ACTIVE_NETWORK=$(sudo iwctl station wlan0 show | awk '/Connected network/ {print $3}')

ROFI_NETWORKS=""
for net in $NETWORKS; do
    if [ "$net" = "$ACTIVE_NETWORK" ]; then
        ROFI_NETWORKS+="$net (connected)\n"
    else
        ROFI_NETWORKS+="$net\n"
    fi
done

if [ -n "$ACTIVE_NETWORK" ]; then
    ROFI_NETWORKS+="Disconnect\n"
fi

echo "Networks found. Displaying with Rofi..."

SELECTED_FULL=$(echo -e "$ROFI_NETWORKS" | rofi -dmenu -i -p "$ROFI_PROMPT" -width 30 -lines 10 -format s)

if [ -z "$SELECTED_FULL" ]; then
    echo "No network selected. Exiting."
    exit 0
fi

SELECTED_NETWORK=$(echo "$SELECTED_FULL" | sed 's/ (connected)//')

echo "You selected: $SELECTED_NETWORK"

if [ "$SELECTED_NETWORK" = "Disconnect" ]; then
    sudo iwctl station wlan0 disconnect
    notify-send "Wi-Fi Disconnected"
    exit 0
fi

if [ "$SELECTED_NETWORK" = "$ACTIVE_NETWORK" ]; then
    exit 0
fi

if [ -z "$WIFI_PASSWORD" ]; then
    read -s -p "Enter password for $SELECTED_NETWORK: " WIFI_PASSWORD
    echo ""
fi

sudo iwctl --passphrase "$WIFI_PASSWORD" station wlan0 connect "$SELECTED_NETWORK" && notify-send "Wi-Fi Connected" "Connected to $SELECTED_NETWORK"