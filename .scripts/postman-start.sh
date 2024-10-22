#!/bin/zsh

setsid /opt/postman/Postman &>/dev/null &
notify-send start

# Wait for Postman window to appear
while ! wmctrl -l | grep -q "Postman"; do
    sleep 0.1
done

sleep 0.5
wmctrl -a Postman
xdotool Mod4+f
