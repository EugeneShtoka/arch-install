#!/bin/zsh

function converertDate() {
	meeting=$1
	meetingName=$(echo $meeting | jq '.summary' | tr -d '\"' | tr -d  ' ')
	date_string=$(echo $meeting | jq '.start' | tr -d '\"')
	date_only=$(date -d $date_string +'%d-%m-%Y')
	if [[ "$date_only" == "`date +'%d-%m-%Y'`" ]]; then
		formatted_date="Today at $(date -d $date_string +'%H:%M')"
	elif [[ "$date_only" == "`date -d '+1 day' +'%d-%m-%Y'`" ]]; then
		formatted_date="Tomorrow at $(date -d $date_string +'%H:%M')"
	else
		formatted_date=$(date -d $date_string +'%A, %d %B %Y at %H:%M')
	fi
	echo $meetingName - $formatted_date
}

function connectToMeeting() {
	meeting=$1
	conf=${$(echo $meeting | jq '.url')##*/}
	conf=$(echo $conf | tr -d '\"' | sed 's/?/\&/')
	setsid xdg-open "zoommtg://zoom.us/join?action=join&video=on&confno=$conf" >/dev/null 2>&1 < /dev/null &
}

eventMap='map({ summary, start: .start.dateTime, end: .end.dateTime, conferenceType: .conferenceData.conferenceSolution.name, url: .conferenceData.entryPoints.[0].uri })'
topLimit=$(date -d '+10 days' +'%Y-%m-%dT%H:%M:%S%z')
meetings=$(~/dev/gcalcli/gcalcli list events --single --orderBy startTime --maxStartTime $topLimit --eventTypes default | jq "$eventMap")
echo $meetings

meetingCount=$(echo "$meetings" | jq '. | length')

if [[ $meetingCount -eq 0 ]]; then
	meeting=$(~/dev/gcalcli/gcalcli list events --single --orderBy startTime --maxResults 1 --eventTypes default | jq "$eventMap" | jq '.[0]')	
	dunstify "Auto Join meetings" "No meetings scheduled soon.<br>Next meeting:<br>  $(converertDate $meeting)";
elif [[ $meetingCount -eq 1 ]]; then
	meeting=$(echo $meetings | jq -c '.[0]')
	$(connectToMeeting $meeting)
else
	availableMeetings=()
	echo "$meetings" | jq -c '.[]' | while read meeting; do
		name=$(converertDate "$meeting")
		availableMeetings+=("$name")
	done
	dir="$HOME/.config/rofi/launchers/type-4"
	theme='style-9a'
	choice=$(printf '%s\n' "${availableMeetings[@]}" | rofi -theme ${dir}/${theme}.rasi -dmenu -matching prefix)
	echo "$meetings" | jq -c '.[]' | while read meeting; do
		name=$(converertDate "$meeting")
		if [[ "$name" == "$choice" ]]; then
			$(connectToMeeting "$meeting")
		fi
	done
fi

