#!/bin/zsh

get_wifi_icon() {
  #local icons=(󰤯 󰤟 󰤢 󰤥 󰤨)
  local icons=( 󰂎 󰁺 󰁻 󰁼 󰁽 󰁾 󰁿 󰂀 󰂁 󰂂 󰁹 ) 
  local index=$(( $1 / 20 + 1))

  printf "${icons[index]}" 
}