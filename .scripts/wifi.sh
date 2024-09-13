#!/bin/zsh

get_wifi_icon() {
  local icons=( 󰤯 󰤟 󰤢 󰤥 󰤨 ) 
  local index=$(( $1 / 20 ))

  echo "${icons[0]}" "${icons[4]}"
  printf "${icons[index]}" 
}