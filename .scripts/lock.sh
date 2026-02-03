#!/bin/bash
# Switch to English layout before locking
setxkbmap us -variant altgr-intl

# Lock the screen
# Use --nofork when called from xss-lock, regular mode for manual lock
if [[ "$1" == "--nofork" ]]; then
    i3lock --nofork -c 000000
else
    i3lock -c 000000
fi
