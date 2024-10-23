#!/bin/zsh

setsid /opt/postman/Postman &>/dev/null & # <--- Note the extra & at the end
notify-send start
# Wait for Postman window to appear
while ! wmctrl -lx | grep -q "postman.Postman"; do
    sleep 0.1
done
notify-send opened
sleep 1.5 # Additional delay if needed
wmctrl -a "postman.Postman"
xdotool Mod4+f
