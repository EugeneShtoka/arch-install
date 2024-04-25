#!/bin/zsh
eventMap='map({ summary, start, end, conferenceType: .conferenceData.conferenceSolution.name, url: .conferenceData.entryPoints.[0].uri })'
topLimit=$(date -d '+8 days' +'%Y-%m-%dT00:00:00%z')
echo $topLimit
meetings=$(~/dev/gcalcli/gcalcli list events --single --orderBy startTime --maxStartTime $topLimit | jq "$eventMap")
echo $meetings

