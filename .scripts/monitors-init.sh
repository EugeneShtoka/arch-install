#!/bin/zsh

monitors=($(xrandr | grep ' connected' | awk '{print $1}'))

echo connecting monitor ${monitors[2]}
xrandr --output ${monitors[2]} --auto --left-of ${monitors[1]} 
sleep 2
echo connecting monitor ${monitors[3]}
xrandr --output ${monitors[3]} --auto --left-of ${monitors[2]}        