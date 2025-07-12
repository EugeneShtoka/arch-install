#!/bin/bash

WIFI_INTERFACE="wlan0"
ROFI_PROMPT="Select Wi-Fi Network  "

NETWORKS=$(sudo iw dev wlan0 scan | awk '/SSID:/ {print $2}' | sort -u)

if [ -z "$NETWORKS" ]; then
    echo "No Wi-Fi networks found. Ensure the interface '$WIFI_INTERFACE' is up and working."
    echo "Also, confirm that 'iwd.service' is running: 'systemctl status iwd.service'"
    exit 1
fi

ACTIVE_NETWORK=$(sudo iwctl station "$WIFI_INTERFACE" show | awk '/Connected network/ {print $3}')

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
    if [ -n "$ACTIVE_NETWORK" ]; then
        echo "Disconnecting from $ACTIVE_NETWORK using iwctl..."
        if sudo iwctl station "$WIFI_INTERFACE" disconnect; then
            echo "Successfully disconnected from $ACTIVE_NETWORK."
            notify-send "Wi-Fi Disconnected" "Disconnected from $ACTIVE_NETWORK"
        else
            echo "Failed to disconnect from $ACTIVE_NETWORK."
        fi
    else
        echo "Not currently connected to any network."
    fi
    exit 0
fi

if [ "$SELECTED_NETWORK" = "$ACTIVE_NETWORK" ]; then
    echo "Already connected to $SELECTED_NETWORK. No action needed."
    exit 0
fi

read -s -p "Enter password for $SELECTED_NETWORK: " WIFI_PASSWORD
echo ""

echo "Attempting to connect to $SELECTED_NETWORK using iwctl..."

sudo iwctl device "$WIFI_INTERFACE" set-property Powered on

if sudo iwctl --passphrase "$WIFI_PASSWORD" station "$WIFI_INTERFACE" connect "$SELECTED_NETWORK"; then
    echo "Successfully connected to $SELECTED_NETWORK."
    notify-send "Wi-Fi Connected" "Connected to $SELECTED_NETWORK"
    echo "Remember to ensure a DHCP client (like systemd-networkd or dhcpcd) is configured to get an IP address."
    echo "If using iwd's built-in DHCP, make sure EnableNetworkConfiguration=true in /etc/iwd/main.conf."
else
    echo "Failed to connect to $SELECTED_NETWORK."
    echo "Please check the password and ensure iwd is running and configured correctly."
    echo "Troubleshoot with 'journalctl -u iwd'."
    notify-send "Wi-Fi Connection Failed" "Could not connect to $SELECTED_NETWORK" -u critical
fi