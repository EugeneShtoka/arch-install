#!/bin/zsh

json_data='[{"name": "Alice", "age": 30},{"name": "Bob", "age": 25}]'

topLimit=$(date -d '+5 days' +'%Y-%m-%dT%H:%M:%S%z')
meetings=$(~/dev/gcalcli/gcalcli list events --single --orderBy startTime --maxStartTime $topLimit --eventTypes default | jq 'map( {summary, start: .start.dateTime, end: .end.dateTime, url: .conferenceData.entryPoints.[0].uri})')
echo "$meetings"
# Iterate over items using a while loop
echo "$meetings" | jq -c '.[]' | while read item; do
	echo "$item" | jq '.fromjson'
    name=$(echo "$item" | jq -r '.summary')
    age=$(echo "$item" | jq -r '.age')
    echo "Name: $name, Age: $age"
done

topLimit=$(date -d '+5 days' +'%Y-%m-%dT%H:%M:%S%z')
meetings=$(~/dev/gcalcli/gcalcli list events --single --orderBy startTime --maxStartTime $topLimit --eventTypes default | jq -c '.[] | [.summary, .start.dateTime, .end.dateTime, .conferenceData.entryPoints.[0].uri]')

meetingArr=$(echo $meetings | jq '.[0]' | tr -d '\"' | tr -d  ' ')
meetingCount=$(echo "$meetingArr" | wc -l)
echo "$(~/dev/gcalcli/gcalcli list events --single --orderBy startTime --maxStartTime $topLimit --eventTypes default | jq )" | jq -c '.[]' | while read item; do
   echo "$item" | jq '.fromjson'
   summary=$(echo "$item" | jq '.summary')
    echo "Name: $summary, Age: $age"
done


if [[ $meetingCount -eq 0 ]]; then
	nextMeeting=$(~/dev/gcalcli/gcalcli list events --single --orderBy startTime --maxResults 1 --eventTypes default | jq '.[] | [.summary, .start.dateTime, .end.dateTime]')	
	meetingName=$(echo $nextMeeting | jq '.[0]' | tr -d '\"' | tr -d  ' ')
	date_string=$(echo $nextMeeting | jq '.[1]' | tr -d '\"')
	date_only=$(date -d $date_string +'%d-%m-%Y')
	if [[ "$date_only" == "date +'%d-%m-%Y'" ]]; then
		formatted_date="Today at $(date -d $date_string +'%H:%M')"
	elif [[ "$date_only" == "`date -d '+1 day' +'%d-%m-%Y'`" ]]; then
		formatted_date="Tomorrow at $(date -d $date_string +'%H:%M')"
	else
		formatted_date=$(date -d $date_string +'%A, %d %B %Y %H:%M')
	fi
	dunstify "Auto Join meetings" "No meetings scheduled soon.<br>Next meeting:<br>  $meetingName - $formatted_date";
elif [[ $meetingCount -eq 1 ]]; then
	conf=${$(echo $meetings | jq '.[3]')##*/}
	conf=$(echo $conf | tr -d '\"' | sed 's/?/\&/')
	setsid xdg-open "zoommtg://zoom.us/join?action=join&video=on&confno=$conf" >/dev/null 2>&1 < /dev/null &
else
	dunstify "Auto Join meetings" "more than one meeting found"
fi