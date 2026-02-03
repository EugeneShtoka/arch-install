#!/bin/bash
# Switch to English layout before locking
setxkbmap us -variant altgr-intl

# Lock the screen (--nofork works for both manual and xss-lock)
i3lock --nofork -c 000000
