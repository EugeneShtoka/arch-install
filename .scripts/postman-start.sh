#!/bin/zsh

setsid /opt/postman/Postman &>/dev/null
sleep 1.5
wmctrl -a Postman
xdotool $mod+f
notify-send test
