#!/bin/zsh

get_battery_info() {
  power_info="$(upower -i /org/freedesktop/UPower/devices/battery_BAT0)"
  battery_level=$(echo "$power_info" | grep percentage | awk '{print $2}' | tr -d %)
  charging=$(echo "$power_info" | grep "power supply" | awk '{print $3}')

  reply=("$battery_level" "$charging")
}

# Battery icon, depending on battery level
get_battery_icon() {
  local icons=( 󰂎 󰁺 󰁻 󰁼 󰁽 󰁾 󰁿 󰂀 󰂁 󰂂 󰁹 ) 
  local index=$(( $1 / 9 ))

  if [ "$2" = "yes" ]; then
    printf "󰂄"
  else
    printf "${icons[index]}" 
  fi
}

get_battery_status() {
  echo "$(get_battery_icon $1 $2) $1%"
}