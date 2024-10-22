#!/bin/zsh

setsid /opt/postman/Postman &>/dev/null
notify-send start && sleep 1.5 && wmctrl -a Postman && xdotool Mod4+f && notify-send test
