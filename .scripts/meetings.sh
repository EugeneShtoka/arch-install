#!/bin/zsh

function formatMeeting() {
	meeting=$1
	echo $(getName $meeting) - $(getDate $meeting '%A, %d %B %Y')$(getiime $meeting)
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
		echo "Today"
	elif [[ "$date" == "`date -d '+1 day' +'%Y-%m-%d'`" ]]; then
		echo "Tomorrow"
	else
        echo $(date -d $startDate +$dateFormat)
    fi
}

function getiime() {
    meeting=$1
	dateTime=$(echo $meeting | jq '.start.dateTime' | tr -d '\"')

    if [[ $dateTime != "null" ]]; then
        echo " at $(date -d $dateTime +'%H:%M')"
	fi
}

function getName() {
    meeting=$1
    echo $(echo $meeting | jq '.summary' | tr -d '\"' | tr -d  ' ')
}