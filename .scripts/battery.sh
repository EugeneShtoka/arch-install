#!/bin/zsh


get_battery_info() {
  power_info="$(upower -i /org/freedesktop/UPower/devices/battery_BAT0)"
  battery_level=$(echo "$power_info" | grep percentage | awk '{print $2}' | tr -d %)
  charging=$(echo "$power_info" | grep "power supply" | awk '{print $3}')

  reply=("$battery_level" "$charging")
}

# Battery icon, depending on battery level
get_battery_icon_old() {
  if [ "$2" = "yes" ]; then
    printf "󰂄"
  elif (( $1 >= 90 )); then
    printf "󰁹"
  elif (( $1 >= 81 )); then
    printf "󰂂"
  elif (( $1 >= 72 )); then
    printf "󰂁"
  elif (( $1 >= 63 )); then
    printf "󰂀"
  elif (( $1 >= 54 )); then
    printf "󰁿"
  elif (( $1 >= 45 )); then 
   printf "󰁾"
  elif (( $1 >= 36 )); then
    printf "󰁽"
  elif (( $1 >= 27 )); then
    printf "󰁼"
  elif (( $1 >= 18 )); then
    printf "󰁻"
  elif (( $1 >= 9 )); then
    printf "󰁺"
  else
    printf "󰂎"
  fi
}

get_battery_icon() {
  local icons=( 󰂎 󰁺 󰁻 󰁼 󰁽 󰁾 󰁿 󰂀 󰂁 󰂂 󰁹 ) 
  local index=$(( $1 / 9 ))  # 100 / 9 is approximately 11

  if [ "$2" = "yes" ]; then
    printf "󰂄"
  else
    echo $index
    printf "${icons[index]}" 
  fi
}

get_battery_status() {
  echo "$(get_battery_icon $1 $2) $1%"
}