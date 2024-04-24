#!/bin/zsh

topLimit=$(date -d '+5 days' +'%Y-%m-%dT%H:%M:%S%z')
echo $topLimit
meetings=$(~/dev/gcalcli/gcalcli list events --single --orderBy startTime --maxStartTime $topLimit --eventTypes default | jq '.[] | [.summary, .start.dateTime, .end.dateTime, .conferenceData.entryPoints.[0].uri]')
meetingArr=($(echo $meetings | jq '.[0]' //\"))
echo "${meetingArr[@]}"