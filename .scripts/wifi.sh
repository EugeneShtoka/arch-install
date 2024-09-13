#!/bin/zsh

get_wifi_icon() {
  local icons=( 󰤯 󰤟 󰤢 󰤥 󰤨 ) 
  local index=$(( $1 / 20 ))

  echo "${icons[0]}" "${icons[4]}"
  echo "${icons[1]}" "${icons[5]}"
  printf "${icons[index]}" 
}