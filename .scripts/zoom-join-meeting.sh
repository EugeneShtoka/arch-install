#!/bin/zsh

meetings=$(~/dev/gcalcli/gcalcli list events --single --maxResults 2 --orderBy startTime --eventTypes default | jq '.[] | [.summary, .start.dateTime, .end.dateTime, .conferenceData.entryPoints.[0].uri]')
echo $meetings