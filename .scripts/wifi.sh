#!/bin/zsh

get_wifi_icon() {
  local icons=( 󰤯 󰤟 󰤢 󰤥 󰤨 ) 
  local index=$(( $1 / 20 ))
  echo $1 $index $icons ${icons[6]}
  printf "${icons[index]}" 
}