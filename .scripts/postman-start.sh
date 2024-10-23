#!/bin/zsh

setsid /opt/postman/Postman &>/dev/null & # <--- Note the extra & at the end
# Wait for Postman window to appear
while ! wmctrl -lx | grep -q "postman.Postman"; do
    sleep 0.1
done
sleep 0.5
xdotool key Super+f
