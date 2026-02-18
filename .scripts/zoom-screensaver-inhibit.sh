#!/bin/bash
# Prevents screen locking during active Zoom meetings.
# Detects a meeting by looking for a Zoom window whose title is NOT the known
# idle/launcher titles. Resets the X screensaver timer every 55s when in a meeting.

while true; do
    meeting_active=false

    while IFS= read -r wid; do
        title=$(xdotool getwindowname "$wid" 2>/dev/null)
        if echo "$title" | grep -qi "meeting"; then
            meeting_active=true
            break
        fi
    done < <(xdotool search --class zoom 2>/dev/null)

    if $meeting_active; then
        printf "meeting active\n"
        xset s reset
    else
        printf "no meeting\n"
    fi

    sleep 120
done
