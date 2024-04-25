#!/bin/zsh

function formatMeeting() {
	meeting=$1
	echo $(getName $meeting) - $(getDate $meeting)
}

function getDate() {
	meeting=$1
	dateTime=$(echo $meeting | jq '.start.dateTime' | tr -d '\"')
    if [ -z "$dateTime" ]; then
        echo OOO"$dateTime"OOO
        startDate=$(date -d $dateTime +'%Y-%m-%d')
    else
        startDate=$(echo $meeting | jq '.start.date' | tr -d '\"')
    fi
	
	if [[ "$date" == "`date +'%Y-%m-%d'`" ]]; then
		startDate="Today"
	elif [[ "$date" == "`date -d '+1 day' +'%Y-%m-%d'`" ]]; then
		startDate="Tomorrow"
	else
        startDate=$(date -d $startDate +'%A, %d %B %Y')
    fi

    if [ -n "$dateTime" ]; then
        echo "$startDate at $(date -d $dateTime +'%H:%M')"
    else
        echo "$startDate"
	fi
}

function getName() {
    meeting=$1
    echo $(echo $meeting | jq '.summary' | tr -d '\"' | tr -d  ' ')
}