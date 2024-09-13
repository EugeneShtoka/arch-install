#!/bin/zsh

get_wifi_icon() {
  local icons=( 󰤯 󰤟 󰤢 󰤥 󰤨 ) 
  local index=$(( $1 / 20 ))

  echo aa $1 $index
  printf "${icons[0]}" 
  printf "${icons[1]}" 
  printf "${icons[2]}" 
  printf "${icons[3]}" 
  printf "${icons[4]}" 
  printf "${icons[5]}" 

  printf "${icons[index]}" 
}