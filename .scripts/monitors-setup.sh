#!/bin/bash

monitors=($(xrandr | grep ' connected' | awk '{print $1}'))

xrandr --output DP-1-8 --auto --right-of eDP-1
sleep 3
xrandr --output DP-1-1-8 --auto --right-of DP-1-8       