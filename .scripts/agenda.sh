#!/bin/zsh

source $SCRIPTS_PATH/meetings.sh

eventMap='map({ summary, start, end, conferenceType: .conferenceData.conferenceSolution.name, url: .conferenceData.entryPoints.[0].uri })'
topLimit=$(date -d '+8 days' +'%Y-%m-%dT00:00:00%z')
meetings=$(~/dev/gcalcli/gcalcli list events --single --orderBy startTime --maxStartTime $topLimit | jq "$eventMap")

meetingCount=$(echo "$meetings" | jq '. | length')
currentDate=""
echo "$meetings" | jq -c '.[]' | while read meeting; do
	date=$(getDate "$meeting" '%d %B %Y')
	if [ "$date" != "$currentDate" ]; then
		echo "$date"
		currentDate=$date
	fi
	unset startTime
	dateTime=$(echo $meeting | jq '.start.dateTime' | tr -d '\"')
    if [[ $dateTime == "null" ]]; then
		startTime="\t\t"
	else
        startTime="$(date -d $dateTime +'%H:%M')\t"
    fi
	echo "t\t$startTime$(getName "$meeting")"

done
