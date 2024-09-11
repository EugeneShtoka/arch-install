#!/bin/zsh

# Battery information
battery_level=$(upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep percentage | awk '{print $2}' | tr -d %)

# Battery icon, depending on battery level
get_battery_icon() {
  if (( $1 >= 80 )); then
    printf "\uf240\n"
  elif (( $1 >= 60 )); then
    printf "\uf241\n"
  elif (( $1 >= 40 )); then
    printf "\uf242\n"
  elif (( $1 >= 20 )); then 
   printf "\uf243\n"
  else
    printf "\uf244\n"
  fi
}

get_battery_info() {
  echo "$(get_battery_icon $battery_level) $battery_level%"
}