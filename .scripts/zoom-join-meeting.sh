#!/bin/zsh

source $SCRIPTS_PATH/meetings.sh

function connectToMeeting() {
	meeting=$1
	conferenceType=$(echo $meeting | jq '.conferenceType' | tr -d '\"')
	if [[ "$conferenceType" == "Zoom Meeting" ]]; then
		conf=${$(echo $meeting | jq '.url')##*/}
		conf=$(echo $conf | tr -d '\"' | sed 's/?/\&/')
		setsid xdg-open "zoommtg://zoom.us/join?action=join&video=on&confno=$conf" > /dev/null 2>&1 &
	elif [[ "$conferenceType" == "Google Meet" ]]; then
		url=$(echo $meeting | jq '.url' | tr -d '\"')
		setsid setsid vivaldi-snapshot "$url" > /dev/null 2>&1 &
	fi
}

eventMap='map({ summary, start, end, conferenceType: .conferenceData.conferenceSolution.name, url: .conferenceData.entryPoints.[0].uri })'
topLimit=$(date -d '+10 minutes' +'%Y-%m-%dT%H:%M:%S%z')
meetings=$(~/dev/figoro/figoro list events --single --orderBy startTime --maxStartTime $topLimit --eventTypes default | jq "$eventMap")
meetings=$(echo "$meetings" | jq '[ .[] | select(.conferenceType == "Google Meet" or .conferenceType == "Zoom Meeting" )]')
formatMeeting='%A, %d %B'

meetingCount=$(echo "$meetings" | jq '. | length')

if [[ $meetingCount -eq 0 ]]; then
	meeting=$(~/dev/figoro/figoro list events --single --orderBy startTime --maxResults 1 --eventTypes default | jq "$eventMap" | jq '.[0]')	
	dunstify "Auto Join meetings" "<span font='20px'>No meetings scheduled soon.<br>Next meeting:<br>  $(formatMeeting $meeting $formatMeeting)</span>";
elif [[ $meetingCount -eq 1 ]]; then
	meeting=$(echo $meetings | jq -c '.[0]')
	$(connectToMeeting $meeting)
else
	availableMeetings=()
	echo "$meetings" | jq -c '.[]' | while read meeting; do
		name=$(formatMeeting $meeting $formatMeeting)
		availableMeetings+=("$name")
	done
	dir="$HOME/.config/rofi/launchers/type-4"
	theme='style-9a'
	choice=$(printf '%s\n' "${availableMeetings[@]}" | rofi -theme ${dir}/${theme}.rasi -dmenu -matching prefix)
	echo "$meetings" | jq -c '.[]' | while read meeting; do
		name=$(formatMeeting $meeting $formatMeeting)
		if [[ "$name" == "$choice" ]]; then
			$(connectToMeeting "$meeting")
		fi
	done
fi

