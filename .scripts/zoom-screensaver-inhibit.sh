#!/bin/bash
# Prevents screen locking during active Zoom meetings.
# Detects a meeting by looking for a Zoom window whose title is NOT the known
# idle/launcher titles. Resets the X screensaver timer every 55s when in a meeting.

IDLE_TITLES="Zoom - Free Account|Zoom - Free account|Zoom Cloud Meetings|zoom"

while true; do
    meeting_active=false

    while IFS= read -r wid; do
        title=$(xdotool getwindowname "$wid" 2>/dev/null)
        if [[ -n "$title" ]] && ! echo "$title" | grep -qE "^($IDLE_TITLES)$"; then
            meeting_active=true
            break
        fi
    done < <(xdotool search --class zoom 2>/dev/null)

    if $meeting_active; then
        xset s reset
    fi

    sleep 120
done
