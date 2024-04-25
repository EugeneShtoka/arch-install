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

eventMap='map({ summary, start: .start.dateTime, end: .end.dateTime, conferenceType: .conferenceData.conferenceSolution.name, url: .conferenceData.entryPoints.[0].uri })'
topLimit=$(date -d '+10 days' +'%Y-%m-%dT%H:%M:%S%z')
meetings=$(~/dev/gcalcli/gcalcli list events --single --orderBy startTime --maxStartTime $topLimit --eventTypes default | jq "$eventMap")
meetings=$(echo "$meetings" | jq '[ .[] | select(.conferenceType == "Google Meet" or .conferenceType == "Zoom Meeting" )]')

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
	echo $choice
	echo "$meetings" | jq -c '.[]' | while read meeting; do
		name=$(converertDate "$meeting")
		if [[ "$name" == "$choice" ]]; then
			$(connectToMeeting "$meeting")
		fi
	done
fi

