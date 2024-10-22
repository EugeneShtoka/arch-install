#!/bin/zsh

setsid /opt/postman/Postman &>/dev/null

wmctrl -a Postman
xdotool $mod+f
sleep 1.5 && notify-send test
