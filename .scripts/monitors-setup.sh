#!/bin/bash

echo $1
echo $2
echo $3

xrandr --output DP-1-8 --auto --right-of eDP-1
sleep 3
xrandr --output DP-1-1-8 --auto --right-of DP-1-8       