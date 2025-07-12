#!/bin/bash

# Configuration
WIFI_INTERFACE="wlan0" # <--- IMPORTANT: Replace with your actual Wi-Fi interface name
                        # You can find it using `iwctl device list` or `ip link show`
ROFI_PROMPT="Select Wi-Fi Network  " # Rofi prompt text (U+F1EB is the Font Awesome Wi-Fi icon)

echo "Scanning for Wi-Fi networks on $WIFI_INTERFACE..."

# Ensure iwd is running and the device is powered on
# This is crucial for iwctl commands to work.
sudo iwctl device "$WIFI_INTERFACE" set-property Powered on

# Perform the scan using iwctl
# Note: iwctl station scan doesn't print output immediately,
# it just tells the device to scan.
sudo iwctl station "$WIFI_INTERFACE" scan

# Wait a moment for the scan to complete
sleep 2

# Get the list of available networks using iwctl, extract SSIDs, and sort uniquely.
# We also include a "Disconnect" option for convenience.
NETWORKS_RAW=$(sudo iwctl station "$WIFI_INTERFACE" get-networks)

# Parse SSIDs. We use awk to get the second field and then filter out headers/empty lines.
# We also want to capture "active" networks to display them differently.
AVAILABLE_NETWORKS=$(echo "$NETWORKS_RAW" | awk 'NR > 1 {print $2}' | grep -v '^\s*$' | sort -u)
ACTIVE_NETWORK=$(sudo iwctl station "$WIFI_INTERFACE" show | awk '/Connected network/ {print $3}') # Get currently connected network

# Prepare networks for Rofi, marking the active one
ROFI_NETWORKS=""
for net in $AVAILABLE_NETWORKS; do
    if [ "$net" = "$ACTIVE_NETWORK" ]; then
        ROFI_NETWORKS+="$net (connected)\n"
    else
        ROFI_NETWORKS+="$net\n"
    fi
done

# Add a "Disconnect" option if currently connected
if [ -n "$ACTIVE_NETWORK" ]; then
    ROFI_NETWORKS+="Disconnect\n"
fi

if [ -z "$ROFI_NETWORKS" ]; then
    echo "No Wi-Fi networks found or available. Exiting."
    exit 1
fi

echo "Networks found. Displaying with Rofi..."

# Use Rofi to let the user select a network
SELECTED_FULL=$(echo -e "$ROFI_NETWORKS" | rofi -dmenu -i -p "$ROFI_PROMPT" -width 30 -lines 10 -format s)

if [ -z "$SELECTED_FULL" ]; then
    echo "No network selected. Exiting."
    exit 0
fi

# Extract the actual network name, removing "(connected)" if present
SELECTED_NETWORK=$(echo "$SELECTED_FULL" | sed 's/ (connected)//')

echo "You selected: $SELECTED_NETWORK"

# --- Handle Disconnect Option ---
if [ "$SELECTED_NETWORK" = "Disconnect" ]; then
    if [ -n "$ACTIVE_NETWORK" ]; then
        echo "Disconnecting from $ACTIVE_NETWORK..."
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

# --- Connect using iwctl ---
# Check if already connected to the selected network
if [ "$SELECTED_NETWORK" = "$ACTIVE_NETWORK" ]; then
    echo "Already connected to $SELECTED_NETWORK. No action needed."
    exit 0
fi

read -s -p "Enter password for $SELECTED_NETWORK: " WIFI_PASSWORD
echo "" # Newline after password input

echo "Attempting to connect to $SELECTED_NETWORK using iwctl..."

# Connect to the network using iwctl
# iwctl will prompt for passphrase if not provided or if the network is hidden.
# We're providing it directly with --passphrase.
if sudo iwctl --passphrase "$WIFI_PASSWORD" station "$WIFI_INTERFACE" connect "$SELECTED_NETWORK"; then
    echo "Successfully connected to $SELECTED_NETWORK."
    # Optional: Display a desktop notification
    notify-send "Wi-Fi Connected" "Connected to $SELECTED_NETWORK"
    echo "Remember to ensure a DHCP client (like systemd-networkd or dhcpcd) is configured to get an IP address."
    # If using iwd's built-in DHCP, make sure EnableNetworkConfiguration=true in /etc/iwd/main.conf
else
    echo "Failed to connect to $SELECTED_NETWORK."
    echo "Please check the password and ensure iwd is running and configured correctly."
    echo "Troubleshoot with 'journalctl -u iwd'."
    # Optional: Display a desktop notification
    notify-send "Wi-Fi Connection Failed" "Could not connect to $SELECTED_NETWORK" -u critical
fi