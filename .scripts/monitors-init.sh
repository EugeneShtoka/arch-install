#!/bin/zsh

monitors=($(xrandr | grep ' connected' | awk '{print $1}'))

xrandr --output ${monitors[1]} --auto --right-of eDP-1
sleep 3
xrandr --output ${monitors[2]} --auto --right-of ${monitors[1]}        