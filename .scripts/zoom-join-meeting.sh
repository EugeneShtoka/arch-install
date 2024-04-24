#!/bin/zsh

function converertDate() {
	meeting=$1
	meetingName=$(echo $nextMeeting | jq '.summary' | tr -d '\"' | tr -d  ' ')
	date_string=$(echo $nextMeeting | jq '.start.dateTime' | tr -d '\"')
	date_only=$(date -d $date_string +'%d-%m-%Y')
	if [[ "$date_only" == "date +'%d-%m-%Y'" ]]; then
		formatted_date="Today at $(date -d $date_string +'%H:%M')"
	elif [[ "$date_only" == "`date -d '+1 day' +'%d-%m-%Y'`" ]]; then
		formatted_date="Tomorrow at $(date -d $date_string +'%H:%M')"
	else
		formatted_date=$(date -d $date_string +'%A, %d %B %Y %H:%M')
	fi
	echo $meetingName - $formatted_date
}

json_data='[{"name": "Alice", "age": 30},{"name": "Bob", "age": 25}]'

topLimit=$(date -d '+3 days' +'%Y-%m-%dT%H:%M:%S%z')
meetings=$(~/dev/gcalcli/gcalcli list events --single --orderBy startTime --maxStartTime $topLimit --eventTypes default)
echo "$meetings"
# Iterate over items using a while loop
echo "$meetings" | jq -c '.[]' | while read item; do
	#echo $(converertDate $nextMeeting)
done

meetingCount=$(echo "$meetings" | jq '. | length')
echo $meetingCount

if [[ $meetingCount -eq 0 ]]; then
	nextMeeting=$(~/dev/gcalcli/gcalcli list events --single --orderBy startTime --maxResults 1 --eventTypes default | jq '.[0]')	
	dunstify "Auto Join meetings" "No meetings scheduled soon.<br>Next meeting:<br>  $(converertDate $nextMeeting)";
elif [[ $meetingCount -eq 1 ]]; then
	conf=${$(echo $meetings | jq '.[] | .url')##*/}
	conf=$(echo $conf | tr -d '\"' | sed 's/?/\&/')
	setsid xdg-open "zoommtg://zoom.us/join?action=join&video=on&confno=$conf" >/dev/null 2>&1 < /dev/null &
else
	dunstify "Auto Join meetings" "more than one meeting found"
fi

