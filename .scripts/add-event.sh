#!/bin/zsh

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
BODY='{"contents": [{"parts":[{"text": "Your role is personal assistant. Today is '$DATE' Translate '$1' to english, analyze for expected finish time and prepare json consisting of SUMMARY, LOCATION, DTSTART YYYYMMDDTHHMMSS, DTEND YYYYMMDDTHHMMSS. Timezone is Asia/Jerusalem. Time given in IDT. Return json only."}]}]}'

echo $BODY

json_data=$(curl https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$GEMINI_API_KEY \
    -H 'Content-Type: application/json' \
    -X POST \
    -d "$BODY" 2> /dev/null | jq '.candidates[].content.parts[0].text' | jq 'fromjson')

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
echo "$ics_data" > ~/Downloads/event.ics
vivaldi-snapshot ~/Downloads/event.ics

