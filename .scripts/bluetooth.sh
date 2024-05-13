function bluetooth_status() {
    prrintf "$(bluetoothctl info $HEADPHONES_MAC_ADDR)"
}

function is_bluetooth_connected() {
    echo $(echo "$(bluetooth_status)" | grep Connected | awk '{print $2}')
}

function show-headphones-message() {
    blStatus="$(bluetooth_status)"
    echo "$blStatus"
    name=$(echo "$blStatus" | grep -oP '(?<=Name: ).*' )
    battery_level=$(echo $blStatus | grep -oP '(?<=Battery Percentage: ).*' | awk '{print $2}' | tr -d \(\))
    message="$(get_battery_icon $battery_level) $battery_level% $(get_audio_status)"
    notify-send "$name $1" "$message" -i headphones
}2