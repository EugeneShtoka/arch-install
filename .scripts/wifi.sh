#!/bin/zsh

get_wifi_icon() {
  local icons=( 󰤯 󰤟 󰤢 󰤥 󰤨 ) 
  local index=$(( $1 / 20 ))

  echo aa $1 $index
  printf "${icons[0]}" 

  printf "${icons[index]}" 
}