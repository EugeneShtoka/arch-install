#!/bin/zsh

monitor_flag=()
xrandr | grep -q '^DP-2 connected [^(]' && monitor_flag=(-monitor DP-2)

rofi $monitor_flag "$@"
