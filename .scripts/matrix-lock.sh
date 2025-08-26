#!/bin/bash

# Kill any existing cmatrix processes
pkill cmatrix

# Start cmatrix in background
cmatrix -ab -u 2 &
CMATRIX_PID=$!

# Lock screen with transparent background to show cmatrix
i3lock \
    --insidever-color=ffffff00 \
    --ringver-color=ffffff00 \
    --insidewrong-color=ffffff00 \
    --ringwrong-color=ffffff00 \
    --inside-color=ffffff00 \
    --ring-color=ffffff00 \
    --line-color=ffffff00 \
    --separator-color=ffffff00 \
    --verif-color=ffffff00 \
    --wrong-color=ffffff00 \
    --time-color=ffffff00 \
    --date-color=ffffff00 \
    --layout-color=ffffff00 \
    --keyhl-color=ffffff00 \
    --bshl-color=ffffff00 \
    --screen 1 \
    --blur 5 \
    --clock \
    --indicator \
    --time-str="%H:%M:%S" \
    --date-str="%A, %m %Y"

# Kill cmatrix when lock screen exits
kill $CMATRIX_PID 2>/dev/null
