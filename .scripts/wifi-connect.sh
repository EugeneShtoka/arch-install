#!/bin/zsh

# WiFi Network Selection Script
# Uses rofi to select from known networks and connects to the chosen one

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to get known networks
get_known_networks() {
    # Get list of known networks from NetworkManager
    nmcli -t -f SSID,TYPE,DEVICE connection show --active | \
    grep -E "wifi|wlan" | \
    cut -d: -f1 | \
    sort -u
}

# Function to get available networks
get_available_networks() {
    # Scan for available networks
    nmcli -t -f SSID,SIGNAL,SECURITY device wifi list --rescan yes | \
    grep -v "^$" | \
    sort -k2 -nr | \
    cut -d: -f1
}

# Function to connect to a network
connect_to_network() {
    local ssid="$1"
    
    echo -e "${BLUE}Attempting to connect to: ${YELLOW}$ssid${NC}"
    
    # Try to connect using NetworkManager
    if nmcli device wifi connect "$ssid"; then
        echo -e "${GREEN}Successfully connected to $ssid${NC}"
        return 0
    else
        echo -e "${RED}Failed to connect to $ssid${NC}"
        echo -e "${YELLOW}You may need to enter the password manually${NC}"
        return 1
    fi
}

# Function to show network status
show_network_status() {
    echo -e "${BLUE}Current WiFi Status:${NC}"
    nmcli device wifi list --rescan no | head -10
    echo ""
}

# Main function
main() {
    # Check if NetworkManager is running
    if ! systemctl is-active --quiet NetworkManager; then
        echo -e "${RED}NetworkManager is not running. Please start it first.${NC}"
        exit 1
    fi

    # Check if rofi is installed
    if ! command -v rofi &> /dev/null; then
        echo -e "${RED}rofi is not installed. Please install it first.${NC}"
        exit 1
    fi

    # Show current status
    show_network_status

    # Get known networks
    echo -e "${BLUE}Getting known networks...${NC}"
    known_networks=$(get_known_networks)
    
    if [ -z "$known_networks" ]; then
        echo -e "${YELLOW}No known networks found.${NC}"
        echo -e "${BLUE}Getting available networks...${NC}"
        available_networks=$(get_available_networks)
        
        if [ -z "$available_networks" ]; then
            echo -e "${RED}No available networks found.${NC}"
            exit 1
        fi
        
        # Use available networks
        selected_network=$(echo "$available_networks" | rofi -dmenu -p "Select WiFi Network:")
    else
        # Use known networks
        selected_network=$(echo "$known_networks" | rofi -dmenu -p "Select Known WiFi Network:")
    fi

    # Check if a network was selected
    if [ -z "$selected_network" ]; then
        echo -e "${YELLOW}No network selected. Exiting.${NC}"
        exit 0
    fi

    # Connect to the selected network
    connect_to_network "$selected_network"
}

# Run main function
main "$@" 