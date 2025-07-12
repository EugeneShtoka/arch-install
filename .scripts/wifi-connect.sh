#!/bin/zsh

rofi_dir="$HOME/.config/rofi/launchers/type-4"
rofi_theme='style-9-wide'


get_available_networks() {
    iwctl station wlan0 scan
    sleep 2
    
    iwctl station wlan0 get-networks | \
    grep -E "^[[:space:]]*[A-Za-z0-9_-]+" | \
    awk '{
        ssid = $1
        if (ssid != "" && ssid != "SSID") {
            print ssid
        }
    }' | \
    sort
}

# Function to connect to a network
connect_to_network() {
    local ssid="$1"
    
    echo -e "${BLUE}Attempting to connect to: ${YELLOW}$ssid${NC}"
    
    # Try to connect using iwctl
    if iwctl station wlan0 connect "$ssid"; then
        echo -e "${GREEN}Successfully connected to $ssid${NC}"
        return 0
    else
        echo -e "${RED}Failed to connect to $ssid${NC}"
        echo -e "${YELLOW}You may need to enter the password manually${NC}"
        return 1
    fi
}

# Function to extract SSID from rofi selection
extract_ssid() {
    local selection="$1"
    # Since we're now showing only SSID names, return the selection as is
    echo "$selection"
}

# Function to show network status
show_network_status() {
    echo -e "${BLUE}Current WiFi Status:${NC}"
    iwctl station wlan0 show
    echo ""
}

# Main function
main() {
    # Check if iwctl is available
    if ! command -v iwctl &> /dev/null; then
        echo -e "${RED}iwctl is not installed. Please install iwd package first.${NC}"
        exit 1
    fi

    # Check if rofi is installed
    if ! command -v rofi &> /dev/null; then
        echo -e "${RED}rofi is not installed. Please install it first.${NC}"
        exit 1
    fi

    # Show current status
    show_network_status

    # Get available networks
    echo -e "${BLUE}Scanning for available networks...${NC}"
    available_networks=$(get_available_networks)
    
    if [ -z "$available_networks" ]; then
        echo -e "${RED}No available networks found.${NC}"
        exit 1
    fi
    
    # Show networks in rofi
    selected_network=$(echo "$available_networks" | rofi -i -theme "${rofi_dir}/${rofi_theme}.rasi" -dmenu -p "Select WiFi Network:")
    
    # Check if a network was selected
    if [ -z "$selected_network" ]; then
        echo -e "${YELLOW}No network selected. Exiting.${NC}"
        exit 0
    fi

    # Extract SSID from selection and connect
    ssid=$(extract_ssid "$selected_network")
    connect_to_network "$ssid"
}

# Run main function
main "$@" 