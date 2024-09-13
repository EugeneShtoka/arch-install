#!/bin/bash

# Check if the correct number of arguments is provided
if [ $# -ne 2 ]; then
    echo "Usage: $0 <number> <h|m|s>"
    exit 1
fi

number=$1
unit=$2

# Convert the time to seconds based on the provided unit
case $unit in
    h) seconds=$((number * 3600)) ;;
    m) seconds=$((number * 60)) ;;
    s) seconds=$number ;;
    *) echo "Invalid unit. Use h, m, or s."
       exit 1 ;;
esac

# Sleep for the calculated time
sleep $seconds

# Play a sound using the 'play' command (assuming 'sox' is installed)
play -n synth 0.1 sine 440  # You can customize this sound further
sleep 0.2
play -n synth 0.1 sine 440
sleep 0.2
play -n synth 0.1 sine 440

echo "Time's up!"