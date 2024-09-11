#!/bin/zsh

# Battery icon, depending on battery level
get_battery_icon() {
  if (( $1 >= 80 )); then
    printf "\uf240 $1\%"
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