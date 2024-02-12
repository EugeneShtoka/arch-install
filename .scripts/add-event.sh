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

json_data=$(curl https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$GEMINI_API_KEY \
    -H 'Content-Type: application/json' \
    -X POST \
    -d "$BODY" 2> /dev/null | jq '.candidates[].content.parts[0].text' | jq 'fromjson')