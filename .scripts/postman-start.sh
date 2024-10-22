#!/bin/zsh

setsid /opt/postman/Postman &>/dev/null &

# Wait for Postman window to appear
while ! wmctrl -l | grep -q "Postman"; do
    sleep 0.1
done

wmctrl -a Postman
xdotool Mod4+f
