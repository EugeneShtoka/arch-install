#!/bin/zsh


get_battery_info() {
  power_info="$(upower -i /org/freedesktop/UPower/devices/battery_BAT0)"
  battery_level=$(echo "$power_info" | grep percentage | awk '{print $2}' | tr -d %)
  charge_state=$(echo "$power_info" | grep state | awk '{print $2}')

  reply=("$battery_level" "$charge_state")
}

# Battery icon, depending on battery level
get_battery_icon() {
  echo $2
  if [ "$2" = "charging" ]; then
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

get_battery_status() {
  echo "$(get_battery_icon $1 $2) $1%"
}