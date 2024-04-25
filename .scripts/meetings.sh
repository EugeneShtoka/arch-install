#!/bin/zsh

function formatMeeting() {
	meeting=$1
	echo $(getName $meeting) - $(getDate $meeting)
}

function getDate() {
	meeting=$1
	dateTime=$(echo $meeting | jq '.start.dateTime' | tr -d '\"')
    if [ -n "$dateTime" ]; then
        startDate=$(date -d $dateTime +'%d-%m-%Y')
    else
        tempDate=$(echo $meeting | jq '.start.date' | tr -d '\"')
        startDate=$(date -d $tempDate +'%d-%m-%Y')
    fi
	
	if [[ "$date" == "`date +'%d-%m-%Y'`" ]]; then
		startDate="Today"
	elif [[ "$date" == "`date -d '+1 day' +'%d-%m-%Y'`" ]]; then
		startDate="Tomorrow"
	else
        echo $(date -d "$startDate"T00:00 +'%A, %d %B %Y')
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