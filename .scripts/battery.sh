#!/bin/zsh


get_battery_info() {
  power_info="$(upower -i /org/freedesktop/UPower/devices/battery_BAT0)"
  battery_level=$(echo "$power_info" | grep percentage | awk '{print $2}' | tr -d %)
  charge_state=$(echo "$power_info" | grep state | awk '{print $2}')

  reply=("$battery_level" "$charge_state")
}

# Battery icon, depending on battery level
get_battery_icon() {
  if (( "$2" = "charging" )); then
    printf "\uf1e6"
  # elif (( $1 >= 92 )); then
  #   printf "󰁹"
  # elif (( $1 >= 84 )); then
  #   printf "󰂂"
  # elif (( $1 >= 75 )); then
  #   printf "󰂁"
  # elif (( $1 >= 67 )); then
  #   printf "󰂀"
  elif (( $1 >= 59 )); then
    printf "󰁿"
  elif (( $1 >= 50 )); then 
   printf "\uf243"
  elif (( $1 >= 42 )); then
    printf "󰁹"
  elif (( $1 >= 34 )); then
    printf "󰁹"
  elif (( $1 >= 25 )); then
    printf "󰁹"
  elif (( $1 >= 17 )); then
    printf "\uf241"
  elif (( $1 >= 9 )); then
    printf "\uf242"
  else
    printf "\uf244"
  fi
}

get_battery_status() {
  echo "$(get_battery_icon $1 $2) $1%"
}