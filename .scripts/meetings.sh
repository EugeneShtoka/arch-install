#!/bin/zsh

function formatMeeting() {
	meeting=$1
	echo $(getName $meeting) - $(getDate $meeting '%A, %d %B %Y')
}

function getDate() {
	meeting=$1
    dateFormat=$2
	dateTime=$(echo $meeting | jq '.start.dateTime' | tr -d '\"')
    if [[ $dateTime == "null" ]]; then
        startDate=$(echo $meeting | jq '.start.date' | tr -d '\"')
    else
        startDate=$(date -d $dateTime +'%Y-%m-%d')
    fi
	
	if [[ "$date" == "`date +'%Y-%m-%d'`" ]]; then
		startDate="Today"
	elif [[ "$date" == "`date -d '+1 day' +'%Y-%m-%d'`" ]]; then
		startDate="Tomorrow"
	else
        startDate=$(date -d $startDate +$dateFormat)
    fi

    if [[ $dateTime == "null" ]]; then
        echo "$startDate"
    else
        echo "$startDate at $(date -d $dateTime +'%H:%M')"
	fi
}

function getName() {
    meeting=$1
    echo $(echo $meeting | jq '.summary' | tr -d '\"' | tr -d  ' ')
}