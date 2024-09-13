#!/bin/zsh

get_wifi_icon() {
  #local icons=(󰤯 󰤟 󰤢 󰤥 󰤨)
  local icons=( 󰂎 󰁺 󰁻 󰁼 󰁽 󰁾 󰁿 󰂀 󰂁 󰂂 󰁹 ) 
  local index=$(( $1 / 20 ))
  echo $1 $index $icons ${icons[0]}
  printf "${icons[index]}" 
}