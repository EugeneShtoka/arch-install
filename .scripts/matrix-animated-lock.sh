#!/bin/zsh

# Kill any existing matrix background
pkill -f "cmatrix"
pkill -f "xwinwrap"

# Get screen resolution
RESOLUTION=$(xdpyinfo | grep dimensions | awk '{print $2}')

# Start animated matrix background
xwinwrap -g $RESOLUTION -ov -ni -s -nf -- cmatrix -ab -u 2 -C green -s &
MATRIX_PID=$!

# Wait a moment for matrix to start
sleep 0.5

# Apply transparent lock screen overlay
i3lock-color \
    --background=00000000 \
    --inside-color=00000000 \
    --ring-color=00ff0050 \
    --line-color=00000000 \
    --keyhl-color=00ff00ff \
    --ringver-color=00ff00ff \
    --separator-color=00000000 \
    --insidever-color=00000000 \
    --ringwrong-color=ff000080 \
    --insidewrong-color=00000000 \
    --verif-text="" \
    --wrong-text="" \
    --noinput-text="" \
    --lock-text="" \
    --lockfailed-text="" \
    --radius=0 \
    --ring-width=0

# Clean up matrix background after unlock
kill $MATRIX_PID 2>/dev/null
pkill -f "xwinwrap" 2>/dev/null
