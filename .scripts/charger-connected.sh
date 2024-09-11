power_info="$(upower -i /org/freedesktop/UPower/devices/battery_BAT0)"
battery_level=$(echo "$power_info" | grep percentage | awk '{print $2}' | tr -d %)

notify-send "$name $1" "$message" -i $ICONS_PATH/headphones.png -r 101029