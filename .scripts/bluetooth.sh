function bluetooth_status() {
    echo "$(bluetoothctl info $HEADPHONES_MAC_ADDR)"
}

function is_bluetooth_connected() {
    # Check if bluetooth is powered on first
    if ! bluetoothctl show | grep -q "Powered: yes"; then
        echo "no"
        return
    fi
    
    echo $(timeout 0.5s bluetoothctl info $HEADPHONES_MAC_ADDR | grep Connected | awk '{print $2}')
}

function show-headphones-message() {
    blStatus="$(bluetooth_status)"
    echo "$blStatus"
    name=$(echo "$blStatus" | grep -oP '(?<=Name: ).*')
    battery_level=$(echo "$blStatus" | grep -oP '(?<=Battery Percentage: ).*' | awk '{print $2}' | tr -d \(\))
    message="$(get_battery_status $battery_level)$(get_audio_status)"
    notify-send "$name $1" "$message" -i $ICONS_PATH/headphones.png -r 101043
}
