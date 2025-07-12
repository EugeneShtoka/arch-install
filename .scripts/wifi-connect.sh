#!/bin/bash

# Configuration
WIFI_INTERFACE="wlan0" # <--- IMPORTANT: Replace with your actual Wi-Fi interface name
                        # You can find it using `iwctl device list` or `ip link show`
ROFI_PROMPT="Wi-Fi  " # Rofi prompt text (U+F1EB is the Font Awesome Wi-Fi icon)

echo "Scanning for Wi-Fi networks on $WIFI_INTERFACE..."

# Ensure iwd is running and the device is powered on
# Note: This might require sudo. If iwd is already running and the device is up,
# you might not strictly need this line every time.
sudo iwctl device "$WIFI_INTERFACE" set-property Powered on

# Scan for networks
sudo iwctl station "$WIFI_INTERFACE" scan

# Get the list of available networks, filter out empty SSIDs and duplicates,
# and sort them. We'll add an "Disconnect" option for convenience.
# The `get-networks` command's output structure can vary slightly with versions.
# We're looking for the SSID, usually the second column.
NETWORKS_RAW=$(sudo iwctl station "$WIFI_INTERFACE" get-networks)

# Parse SSIDs. We use awk to get the second field and then filter out headers/empty lines.
# We also want to capture "active" networks to display them differently.
AVAILABLE_NETWORKS=$(echo "$NETWORKS_RAW" | awk 'NR > 1 {print $2}' | grep -v '^\s*$' | sort -u)
ACTIVE_NETWORK=$(echo "$NETWORKS_RAW" | awk '/active/ {print $2}')

# Prepare networks for Rofi, marking the active one
ROFI_NETWORKS=""
for net in $AVAILABLE_NETWORKS; do
    if [ "$net" = "$ACTIVE_NETWORK" ]; then
        ROFI_NETWORKS+="$net (connected)\n"
    else
        ROFI_NETWORKS+="$net\n"
    fi
done

# Add a "Disconnect" option
if [ -n "$ACTIVE_NETWORK" ]; then
    ROFI_NETWORKS+="Disconnect\n"
fi

# Use Rofi to let the user select a network
SELECTED_FULL=$(echo -e "$ROFI_NETWORKS" | rofi -dmenu -i -p "$ROFI_PROMPT" -width 30 -format s -lines 10)

if [ -z "$SELECTED_FULL" ]; then
    echo "No network selected. Exiting."
    exit 0
fi

# Extract the actual network name, removing "(connected)" if present
SELECTED_NETWORK=$(echo "$SELECTED_FULL" | sed 's/ (connected)//')

echo "You selected: $SELECTED_NETWORK"

if [ "$SELECTED_NETWORK" = "Disconnect" ]; then
    if [ -n "$ACTIVE_NETWORK" ]; then
        echo "Disconnecting from $ACTIVE_NETWORK..."
        if sudo iwctl station "$WIFI_INTERFACE" disconnect; then
            echo "Successfully disconnected."
        else
            echo "Failed to disconnect."
        fi
    else
        echo "Not currently connected to any network."
    fi
    exit 0
fi

# Check if already connected to the selected network
if [ "$SELECTED_NETWORK" = "$ACTIVE_NETWORK" ]; then
    echo "Already connected to $SELECTED_NETWORK. No action needed."
    exit 0
fi

read -s -p "Enter password for $SELECTED_NETWORK: " WIFI_PASSWORD
echo "" # Newline after password input

echo "Attempting to connect to $SELECTED_NETWORK..."

# Connect to the network
if sudo iwctl station "$WIFI_INTERFACE" connect "$SELECTED_NETWORK" --passphrase "$WIFI_PASSWORD"; then
    echo "Successfully connected to $SELECTED_NETWORK."
    # Optional: Display a notification (requires 'notify-send' or similar)
    # notify-send "Wi-Fi Connected" "Connected to $SELECTED_NETWORK"
else
    echo "Failed to connect to $SELECTED_NETWORK."
    echo "Please check the password and try again, or troubleshoot with 'journalctl -u iwd'."
    # Optional: Display a notification
    # notify-send "Wi-Fi Connection Failed" "Could not connect to $SELECTED_NETWORK" -u critical
fi