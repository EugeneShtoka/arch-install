#!/bin/zsh

setsid /opt/postman/Postman &>/dev/null & # <--- Note the extra & at the end

sleep 1.5 # Additional delay if needed
wmctrl -a Postman
xdotool Mod4+f
