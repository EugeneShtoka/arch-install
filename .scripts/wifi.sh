#!/bin/zsh

get_wifi_icon() {
  local icons=( 󰤯 󰤟 󰤢 󰤥 󰤨 ) 
  local index=$(( $1 / 20 ))

  echo 0:"${icons[0]}" 1:"${icons[1]}" 2:"${icons[2]}" 3:"${icons[3]}" 4:"${icons[4]}" 5:"${icons[5]}\n"
  printf "${icons[index]}" 
}