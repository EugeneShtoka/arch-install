#!/bin/bash

# Configuration
WIFI_INTERFACE="wlan0" # <--- IMPORTANT: Replace with your actual Wi-Fi interface name
                        # You can find it using `iwctl device list` or `ip link show`
ROFI_PROMPT="Select Wi-Fi Network  " # Rofi prompt text (U+F1EB is the Font Awesome Wi-Fi icon)

echo "Scanning for Wi-Fi networks on $WIFI_INTERFACE..."

# Ensure the wireless interface is up and ready for scanning
# This command might not be strictly necessary if your network manager already handles it,
# but it ensures the device is powered on.
sudo iw dev "$WIFI_INTERFACE" set power_save off # Often good to disable power save during scans
sudo ip link set dev "$WIFI_INTERFACE" up

# Perform the scan and extract unique SSIDs.
# We'll use awk to grab the SSID and then sort/uniq for a clean list.
NETWORKS=$(sudo iw dev "$WIFI_INTERFACE" scan | awk '/SSID:/ {print $2}' | sort -u)

if [ -z "$NETWORKS" ]; then
    echo "No Wi-Fi networks found. Exiting."
    exit 1
fi

echo "Networks found. Displaying with Rofi..."

# Use Rofi to let the user select a network
# -dmenu: Run in dmenu mode (text input/selection)
# -i: Case-insensitive filtering
# -p "$ROFI_PROMPT": Set the prompt text
# -width 30: Set Rofi window width (optional)
# -lines 10: Set max number of lines to display (optional)
# -format s: Output the selected string
SELECTED_NETWORK=$(echo -e "$NETWORKS" | rofi -dmenu -i -p "$ROFI_PROMPT" -width 30 -lines 10 -format s)

if [ -z "$SELECTED_NETWORK" ]; then
    echo "No network selected. Exiting."
    exit 0
fi

echo "You selected: $SELECTED_NETWORK"

read -s -p "Enter password for $SELECTED_NETWORK: " WIFI_PASSWORD
echo "" # Newline after password input

echo "Attempting to connect to $SELECTED_NETWORK using nmcli (NetworkManager)..."
echo "Note: iw cannot handle WPA/WPA2/WPA3. We'll use nmcli for the actual connection."

# --- Connect using nmcli (recommended for WPA/WPA2/WPA3) ---
# Check if NetworkManager is available and active
if ! command -v nmcli &> /dev/null || ! systemctl is-active --quiet NetworkManager; then
    echo "Error: NetworkManager is not running or nmcli is not installed."
    echo "Connecting to WPA/WPA2/WPA3 networks requires a network manager (e.g., NetworkManager, iwd)."
    echo "Please ensure NetworkManager or iwd is properly configured and running."
    exit 1
fi

if nmcli dev wifi connect "$SELECTED_NETWORK" password "$WIFI_PASSWORD" ifname "$WIFI_INTERFACE"; then
    echo "Successfully connected to $SELECTED_NETWORK."
    # Optional: Display a desktop notification
    notify-send "Wi-Fi Connected" "Connected to $SELECTED_NETWORK"
else
    echo "Failed to connect to $SELECTED_NETWORK."
    echo "Please check the password and try again."
    echo "You can check NetworkManager logs with 'journalctl -u NetworkManager'."
    # Optional: Display a desktop notification
    notify-send "Wi-Fi Connection Failed" "Could not connect to $SELECTED_NETWORK" -u critical
fi

# Re-enable power save after connection if it was disabled
# sudo iw dev "$WIFI_INTERFACE" set power_save on