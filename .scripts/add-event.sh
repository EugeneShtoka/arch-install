#!/bin/bash

# ICS data
ics_data='BEGIN:VCALENDAR
CALSCALE:GREGORIAN
BEGIN:VEVENT
DTSTART;TZID=Asia/Jerusalem:
DTEND;TZID=Asia/Jerusalem:
SUMMARY:
LOCATION:
END:VEVENT
END:VCALENDAR'

GEMINI_API_KEY=$(bw get item 'Gemini API Key' | jq '.notes' |  tr -d \")

DATE=`date`
BODY='{"contents": [{"parts":[{"text": "today is '$DATE' what is tomorrow date"}]}], "model": "gemini-ultra"}'

echo $BODY

json_data=$(curl https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$GEMINI_API_KEY \
    -H 'Content-Type: application/json' \
    -X POST \
    -d "$BODY" 2> /dev/null)

echo "$json_data"

summary=$(echo "$json_data" | jq -r '.SUMMARY')
location=$(echo "$json_data" | jq -r '.LOCATION')
dtstart=$(echo "$json_data" | jq -r '.DTSTART')
dtend=$(echo "$json_data" | jq -r '.DTEND')

# Replace placeholders in the ICS data
ics_data=$(echo "$ics_data" | sed "s/SUMMARY:/SUMMARY:$summary/")
ics_data=$(echo "$ics_data" | sed "s/LOCATION:/LOCATION:$location/")
ics_data=$(echo "$ics_data" | sed "s/DTSTART;TZID=Asia\/Jerusalem:/DTSTART;TZID=Asia\/Jerusalem:$dtstart/")
ics_data=$(echo "$ics_data" | sed "s/DTEND;TZID=Asia\/Jerusalem:/DTEND;TZID=Asia\/Jerusalem:$dtend/")

# Print the updated ICS data
echo "$ics_data"
# > ~/Downloads/event.ics
# vivaldi-snapshot ~/Downloads/event.ics

