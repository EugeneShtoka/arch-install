#!/bin/zsh

get_battery_info() {
  power_info="$(upower -i /org/freedesktop/UPower/devices/battery_BAT0)"
  battery_level=$(echo "$power_info" | grep percentage | awk '{print $2}' | tr -d %)
  discharging=$(echo "$power_info" | grep "state" | awk '{print $2}')

  reply=("$battery_level" "$discharging")
}

# Battery icon, depending on battery level
get_battery_icon() {
  local icons=( 󰂎 󰁺 󰁻 󰁼 󰁽 󰁾 󰁿 󰂀 󰂁 󰂂 󰁹 ) 
  local index=$(( $1 / 9 ))

  printf "${icons[index]} $1" 
}

get_battery_status() {
  if [ "$2" != "discharging" ]; then
    printf "󰂄 $1%%"
  else
    echo "$(get_battery_icon $1)"
  fi
}