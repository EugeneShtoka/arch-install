#!/bin/bash

source $SCRIPTS_PATH/beep.sh

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

beep 0.03 440
beep 0.03 440