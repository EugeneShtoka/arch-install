#!/bin/zsh

rofi_dir="$HOME/.config/rofi/launchers/type-4"
rofi_theme='style-9-wide'


get_available_networks() {
    # Scan for currently available networks
    iwctl station wlan0 scan
    sleep 2
    
    # Get currently available networks
    local available_ssids=$(iwctl station wlan0 get-networks | \
        grep -E "^[[:space:]]*[A-Za-z0-9_-]+" | \
        awk '{
            ssid = $1
            if (ssid != "" && ssid != "SSID" && ssid != "Available") {
                print ssid
            }
        }' | sort)
    
    # Get known networks from iwd configuration directory
    local known_ssids=""
    if [ -d "/var/lib/iwd" ]; then
        known_ssids=$(sudo find /var/lib/iwd -name "*.psk" -o -name "*.open" | \
            sed 's|/var/lib/iwd/||' | \
            sed 's|\.psk$||' | \
            sed 's|\.open$||' | sort)
    fi
    
    # Find intersection of available and known networks
    if [ -n "$known_ssids" ]; then
        echo "$available_ssids" | grep -Fxf <(echo "$known_ssids")
    else
        echo "No known networks found"
    fi
}

# Function to connect to a network
connect_to_network() {
    local ssid="$1"
    
    echo -e "Attempting to connect to: $ssid"
    
    # Try to connect using iwctl
    if iwctl station wlan0 connect "$ssid"; then
        echo -e "Successfully connected to $ssid"
        return 0
    else
        echo -e "Failed to connect to $ssid"
        echo -e "You may need to enter the password manually"
        return 1
    fi
}

main() {
    echo -e "Getting known networks..."
    available_networks=$(get_available_networks)
    
    if [ -z "$available_networks" ]; then
        echo -e "No available networks found."
        exit 1
    fi
    
    selected_network=$(echo "$available_networks" | rofi -i -theme "${rofi_dir}/${rofi_theme}.rasi" -dmenu -p "Select WiFi Network:")
    
    if [ -z "$selected_network" ]; then
        echo -e "No network selected. Exiting."
        exit 0
    fi

    connect_to_network "$selected_network"
}

main "$@" 