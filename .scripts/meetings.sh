#!/bin/zsh

function formatMeeting() {
	meeting=$1
	echo $(getName $meeting) - $(getDate $meeting)
}

function getDate() {
	meeting=$1
	dateTime=$(echo $meeting | jq '.start.dateTime' | tr -d '\"')
    startTime=""
    if [ -n "$string" ]; then
        startDate=$(date -d $startDate +'%d-%m-%Y')
        startTime=$(date -d $startDate +'%H:%M')
    else
        
    fi
	
	if [[ "$date" == "`date +'%d-%m-%Y'`" ]]; then
		 echo "Today at $(date -d $date_string +'%H:%M')"
	elif [[ "$date" == "`date -d '+1 day' +'%d-%m-%Y'`" ]]; then
		echo "Tomorrow at $(date -d $date_string +'%H:%M')"
	else
        if [ -n "$startTime" ]; then
		    echo $(date -d $date_string +'%A, %d %B %Y at %H:%M')
        else
             echo $(date -d $date_string +'%A, %d %B %Y at %H:%M')
	fi
}

function getName() {
    meeting=$1
    echo $(echo $meeting | jq '.summary' | tr -d '\"' | tr -d  ' ')
}