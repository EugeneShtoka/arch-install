#!/bin/zsh

source $SCRIPTS_PATH/meetings.sh

eventMap='map({ summary, start, end, conferenceType: .conferenceData.conferenceSolution.name, url: .conferenceData.entryPoints.[0].uri })'
topLimit=$(date -d '+8 days' +'%Y-%m-%dT00:00:00%z')
meetings=$(~/dev/gcalcli/gcalcli list events --single --orderBy startTime --maxStartTime $topLimit | jq "$eventMap")

meetingCount=$(echo "$meetings" | jq '. | length')
currentDate=""
agenda=""
echo "$meetings" | jq -c '.[]' | while read meeting; do
	date=$(getDate "$meeting" '%d %B')
	if [ "$date" != "$currentDate" ]; then
		agenda+="$date"
		currentDate=$date
	fi
	unset startTime
	dateTimeStart=$(echo $meeting | jq '.start.dateTime' | tr -d '\"')
	dateTimeEnd=$(echo $meeting | jq '.end.dateTime' | tr -d '\"')
    if [[ $dateTimeStart == "null" ]]; then
		startTime="\t\t"
	else
        startTime="$(date -d $dateTimeStart +'%H:%M') - $(date -d $dateTimeEnd +'%H:%M')\t"
    fi
	agenda+="\t$startTime$(getName "$meeting")"
done

echo "$agenda"
