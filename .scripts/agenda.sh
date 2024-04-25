#!/bin/zsh
eventMap='map({ summary, start: .start.dateTime, end: .end.dateTime, conferenceType: .conferenceData.conferenceSolution.name, url: .conferenceData.entryPoints.[0].uri })'
topLimit=$(date -d '+1 days' +'%Y-%m-%dT00:00:00%z')
echo $topLimit
meetings=$(~/dev/gcalcli/gcalcli list events --single --orderBy startTime --maxStartTime $topLimit --eventTypes default | jq "$eventMap")
meetings=$(echo "$meetings" | jq '[ .[] | select(.conferenceType == "Google Meet" or .conferenceType == "Zoom Meeting" )]')
echo $meetings

