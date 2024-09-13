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
  elif (( $1 >= 80 )); then
    printf "\uf240"
  elif (( $1 >= 60 )); then
    printf "\uf241"
  elif (( $1 >= 40 )); then
    printf "\uf242"
  elif (( $1 >= 20 )); then 
   printf "\uf243"
  else
    printf "\uf244"
  fi
}

get_battery_status() {
  echo "$(get_battery_icon $1 $2) $1%"
}