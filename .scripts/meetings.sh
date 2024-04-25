#!/bin/zsh

function formatMeeting() {
	meeting=$1
	
	date_string=$(echo $meeting | jq '.start' | tr -d '\"')
	date_only=$(date -d $date_string +'%d-%m-%Y')
	if [[ "$date_only" == "`date +'%d-%m-%Y'`" ]]; then
		formatted_date="Today at $(date -d $date_string +'%H:%M')"
	elif [[ "$date_only" == "`date -d '+1 day' +'%d-%m-%Y'`" ]]; then
		formatted_date="Tomorrow at $(date -d $date_string +'%H:%M')"
	else
		formatted_date=$(date -d $date_string +'%A, %d %B %Y at %H:%M')
	fi
	echo $(getName $meeting) - $(getDate $meeting)
}

function getDate() {
	meeting=$1
	date_string=$(echo $meeting | jq '.start' | tr -d '\"')
	date_only=$(date -d $date_string +'%d-%m-%Y')
	if [[ "$date_only" == "`date +'%d-%m-%Y'`" ]]; then
		 echo "Today at $(date -d $date_string +'%H:%M')"
	elif [[ "$date_only" == "`date -d '+1 day' +'%d-%m-%Y'`" ]]; then
		echo "Tomorrow at $(date -d $date_string +'%H:%M')"
	else
		echo $(date -d $date_string +'%A, %d %B %Y at %H:%M')
	fi
}

function getName() {
    meeting=$1
    echo $(echo $meeting | jq '.summary' | tr -d '\"' | tr -d  ' ')
}