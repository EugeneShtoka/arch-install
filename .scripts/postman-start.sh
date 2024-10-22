#!/bin/zsh

setsid /opt/postman/Postman &>/dev/null & # <--- Note the extra & at the end

notify-send start

# Wait for Postman window to appear
while ! wmctrl -l | grep -q "Postman"; do
    sleep 0.1
done

sleep 1.5 # Additional delay if needed
wmctrl -a Postman
xdotool Mod4+f
notify-send test
