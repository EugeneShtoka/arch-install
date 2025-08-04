#!/bin/bash

source $SCRIPTS_PATH/beep.sh

# Check if the correct number of arguments is provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 <HH:MM>"
    echo "Example: $0 14:30 (for 2:30 PM)"
    exit 1
fi

alarm_time=$1

# Validate time format (HH:MM)
if ! [[ $alarm_time =~ ^[0-9]{1,2}:[0-9]{2}$ ]]; then
    echo "Invalid time format. Use HH:MM (e.g., 14:30)"
    exit 1
fi

# Extract hours and minutes
IFS=':' read -r hours minutes <<<"$alarm_time"

# Validate hours and minutes ranges
if [ $hours -lt 0 ] || [ $hours -gt 23 ] || [ $minutes -lt 0 ] || [ $minutes -gt 59 ]; then
    echo "Invalid time. Hours must be 0-23, minutes must be 0-59"
    exit 1
fi

# Get current time in seconds since midnight
current_seconds=$(date +%s)
current_midnight=$(date -d "today 00:00:00" +%s)
current_time_today=$((current_seconds - current_midnight))

# Calculate target time in seconds since midnight
target_time_today=$((hours * 3600 + minutes * 60))

# Check if target time is in the future
if [ $target_time_today -le $current_time_today ]; then
    echo "Error: Specified time $alarm_time has already passed today"
    exit 1
fi

# Calculate seconds to wait (target time is later today)
seconds_to_wait=$((target_time_today - current_time_today))

# Display when the alarm will go off
echo "Alarm set for today at $alarm_time"

echo "Waiting for $(($seconds_to_wait / 3600))h $(($seconds_to_wait % 3600 / 60))m $(($seconds_to_wait % 60))s..."

# Run the alarm in completely detached background process
nohup bash -c "
    sleep $seconds_to_wait
    beep
    beep
    beep
" &

# Get the background process ID
alarm_pid=$!

echo "Alarm running in background (PID: $alarm_pid)"
echo "To cancel the alarm, run: kill $alarm_pid"
