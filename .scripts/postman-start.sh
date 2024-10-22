#!/bin/zsh

setsid /opt/postman/Postman &>/dev/null
sleep 0.5
wmctrl -a Postman
xdotool $mod+f
