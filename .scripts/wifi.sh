#!/bin/zsh

get_wifi_icon() {
  local icons=( 󰤯 󰤟 󰤢 󰤥 󰤨 ) 
  local index=$(( $1 / 20 ))

  echo aa $1 $index
  echo ${icons[1]}
  printf "${icons[index]}" 
}