blStatus=$(bluetoothctl info $HEADPHONES_MAC_ADDR)

function bluetooth_status() {
    echo $(bluetoothctl info $HEADPHONES_MAC_ADDR)
}

function show-headphones-message() {
    blStatus=$(bluetoothctl info $HEADPHONES_MAC_ADDR)
    name=$(echo $blStatus | grep -oP '(?<=Name: ).*' )
    battery_level=$(echo $blStatus | grep -oP '(?<=Battery Percentage: ).*' | awk '{print $2}' | tr -d \(\))
    message="$(get_battery_icon $battery_level) $battery_level% $(get_audio_status)"
    notify-send "$name $1" "$message" -i headphones
}