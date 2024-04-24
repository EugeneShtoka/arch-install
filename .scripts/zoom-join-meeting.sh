#!/bin/zsh

topLimit=$(date -d '+10 minutes' +'%Y-%m-%dT%H:%M:%S%z')
meetings=$(~/dev/gcalcli/gcalcli list events --single --orderBy startTime --maxStartTime $topLimit --eventTypes default | jq '.[] | [.summary, .start.dateTime, .end.dateTime, .conferenceData.entryPoints.[0].uri]')
meetingArr=($(echo $meetings | jq '.[0]' | tr -d '\"'))
meetingCount=${#meetingArr[@]}

if [[ $meetingCount -eq 0 ]]; then
	nextMeeting=$(~/dev/gcalcli/gcalcli list events --single --orderBy startTime --maxResults 1 --eventTypes default | jq '.[] | [.summary, .start.dateTime, .end.dateTime]')	
	meetingName=($(echo $nextMeeting | jq '.[0]' | tr -d '\"'))
	echo $meetingName $(echo $nextMeeting | jq '.[0]')
	dunstify "Auto Join meetings" "no meetings found"
elif [[ $meetingCount -eq 1 ]]; then
	conf=${$(echo $meetings | jq '.[3]')##*/}
	conf=$(echo $conf | tr -d '\"' | sed 's/?/\&/')
	setsid xdg-open "zoommtg://zoom.us/join?action=join&video=on&confno=$conf" >/dev/null 2>&1 < /dev/null &
else
	dunstify "Auto Join meetings" "more than one meeting found"
fi