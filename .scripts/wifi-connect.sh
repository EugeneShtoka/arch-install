#!/bin/bash
dir="$HOME/.config/rofi/launchers/type-4"
theme='style-9'

ROFI_PROMPT="Select Wi-Fi Network  "

ALL_NETWORKS=$(sudo iw dev wlan0 scan | awk '/^[[:space:]]*SSID:/ {sub(/^[[:space:]]*SSID:[[:space:]]*/, ""); print}' | sort -u)
KNOWN_NETWORKS=$(sudo find /var/lib/iwd/ -name "*.psk" -type f 2>/dev/null | sed 's|/var/lib/iwd/||' | sed 's|\.psk$||')

NETWORKS=""
while IFS= read -r net; do
    if [ -n "$net" ] && echo "$KNOWN_NETWORKS" | grep -q "^$net$"; then
        NETWORKS+="$net\n"
    fi
done <<< "$ALL_NETWORKS"
NETWORKS=$(echo -e "$NETWORKS" | grep -v '^$')

if [ -z "$NETWORKS" ]; then
    echo "No Wi-Fi networks found. Ensure the interface wlan0 is up and working."
    echo "Also, confirm that 'iwd.service' is running: 'systemctl status iwd.service'"
    exit 1
fi

ACTIVE_NETWORK=$(sudo iwctl station wlan0 show | awk '/Connected network/ {sub(/^[[:space:]]*Connected network[[:space:]]*/, ""); print}')

ROFI_NETWORKS=""
while IFS= read -r net; do
    if [ -n "$net" ]; then
        if [ "$net" = "$ACTIVE_NETWORK" ]; then
            ROFI_NETWORKS+="$net (connected)\n"
        else
            ROFI_NETWORKS+="$net\n"
        fi
    fi
done <<< "$NETWORKS"

if [ -n "$ACTIVE_NETWORK" ]; then
    ROFI_NETWORKS+="Disconnect\n"
fi

SELECTED_FULL=$(echo -e "$ROFI_NETWORKS" | rofi -theme "$dir/$theme.rasi" -dmenu -matching prefix -theme-str 'inputbar { enabled: false; }')

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

sudo iwctl station wlan0 connect "$SELECTED_NETWORK"