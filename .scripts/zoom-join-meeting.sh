#!/bin/zsh

function converertDate() {
	meeting=$1
	meetingName=$(echo $meeting | jq '.summary' | tr -d '\"' | tr -d  ' ')
	date_string=$(echo $meeting | jq '.start' | tr -d '\"')
	date_only=$(date -d $date_string +'%d-%m-%Y')
	if [[ "$date_only" == "date +'%d-%m-%Y'" ]]; then
		formatted_date="Today at $(date -d $date_string +'%H:%M')"
	elif [[ "$date_only" == "`date -d '+1 day' +'%d-%m-%Y'`" ]]; then
		formatted_date="Tomorrow at $(date -d $date_string +'%H:%M')"
	else
		formatted_date=$(date -d $date_string +'%A, %d %B %Y at %H:%M')
	fi
	echo $meetingName - $formatted_date
}

eventMap='map({ summary, start: .start.dateTime, end: .end.dateTime, url: .conferenceData.entryPoints.[0].uri })'
topLimit=$(date -d '+5 days' +'%Y-%m-%dT%H:%M:%S%z')
meetings=$(~/dev/gcalcli/gcalcli list events --single --orderBy startTime --maxStartTime $topLimit --eventTypes default | jq "$eventMap")
# Iterate over items using a while loop
i=0
numbered_options=()
echo "$meetings" | jq -c '.[]' | while read meeting; do
	((i++))
	name=$(converertDate "$meeting")
	numbered_options+=("$i $name")
	conf=${$(echo $meeting | jq '.url')##*/}
	command=$(echo $conf | tr -d '\"' | sed 's/?/\&/')
	cmds["$name"]="$command"
done
echo "$cmds"

meetingCount=$(echo "$meetings" | jq '. | length')
echo $meetingCount

if [[ $meetingCount -eq 0 ]]; then
	nextMeeting=$(~/dev/gcalcli/gcalcli list events --single --orderBy startTime --maxResults 1 --eventTypes default | jq "$eventMap" | jq '.[0]')	
	dunstify "Auto Join meetings" "No meetings scheduled soon.<br>Next meeting:<br>  $(converertDate $nextMeeting)";
elif [[ $meetingCount -eq 1 ]]; then
	conf=${$(echo $meetings | jq '.[] | .url')##*/}
	conf=$(echo $conf | tr -d '\"' | sed 's/?/\&/')
	setsid xdg-open "zoommtg://zoom.us/join?action=join&video=on&confno=$conf" >/dev/null 2>&1 < /dev/null &
else
	dunstify "Auto Join meetings" "more than one meeting found"
fi

