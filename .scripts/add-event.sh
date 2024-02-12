#!/bin/bash

# ICS data
ics_data='BEGIN:VCALENDAR
VERSION:2.0
PRODID:-//ical.gemini.com//iCal Event Maker
CALSCALE:GREGORIAN
BEGIN:VTIMEZONE
TZID:Asia/Jerusalem
LAST-MODIFIED:20231222T233358Z
TZURL:https://www.tzurl.org/zoneinfo-outlook/Asia/Jerusalem
X-LIC-LOCATION:Asia/Jerusalem
BEGIN:DAYLIGHT
TZNAME:IDT
TZOFFSETFROM:+0200
TZOFFSETTO:+0300
DTSTART:19700327T020000
RRULE:FREQ=YEARLY;BYMONTH=3;BYDAY=-1FR
END:DAYLIGHT
BEGIN:STANDARD
TZNAME:IST
RRULE:FREQ=YEARLY;BYMONTH=10;BYDAY=-1SU
END:STANDARD
END:VTIMEZONE
BEGIN:VEVENT
DTSTAMP:20240212T140125Z
UID:1707746452381-15065@ical.gemini.com
DTSTART;TZID=Asia/Jerusalem:
DTEND;TZID=Asia/Jerusalem:
SUMMARY:
LOCATION:
END:VEVENT
END:VCALENDAR'

GEMINI_API_KEY=$(bw get item 'Gemini API Key' | jq '.notes' |  tr -d \")

BODY='{"contents": [{"parts":[{"text": "Translate '$1' to english, analyze for expected finish time and prepare json consisting of SUMMARY, LOCATION, DTSTART YYYY-MM-DDTHH:MM:SSZ, DTEND YYYY-MM-DDTHH:MM:SSZ. Return json only"}]}],
"generationConfig": {
            "stopSequences": [
                "Title"
            ],
            "temperature": 0.2,
            "maxOutputTokens": 800,
            "topP": 1,
            "topK": 10
        }}'

#json_data=$(curl https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$GEMINI_API_KEY \
#    -H 'Content-Type: application/json' \
#    -X POST \
#    -d "$BODY" 2> /dev/null | jq '.candidates[].content.parts[0].text' | jq 'fromjson')

json_data='{
  "SUMMARY": "Thyroid Ultrasound",
  "LOCATION": "96 Yigal Alon St. Building C, Tel Aviv, 3rd Floor",
  "DTSTART": "2024-02-22T16:00:00Z",
  "DTEND": "2024-02-22T17:30:00Z"
}'

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
echo $ics_data