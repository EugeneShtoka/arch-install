#!/bin/zsh

function formatMeeting() {
	meeting=$1
    dateFormat=$2
	echo $(getName $meeting) - $(getDate $meeting $dateFormat)$(getiime $meeting)
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

function agenda() {
    daysToShow=$1
	eventMap='map({ summary, start, end, conferenceType: .conferenceData.conferenceSolution.name, url: .conferenceData.entryPoints.[0].uri })'
    addition="+$daysToShow days"
    echo $addition
	topLimit=$(date -d $addition +'%Y-%m-%dT00:00:00%z')
    echo $topLimit
	meetings=$(~/dev/gcalcli/gcalcli list events --single --orderBy startTime --maxStartTime $topLimit | jq "$eventMap")

	meetingCount=$(echo "$meetings" | jq '. | length')
	currentDate=""
	agenda=""
	echo "$meetings" | jq -c '.[]' | while read meeting; do
		date=$(getDate "$meeting" '%d %B')
		if [ "$date" != "$currentDate" ]; then
			agenda+="$date\n"
			currentDate=$date
		fi
		unset startTime
		dateTimeStart=$(echo $meeting | jq '.start.dateTime' | tr -d '\"')
		dateTimeEnd=$(echo $meeting | jq '.end.dateTime' | tr -d '\"')
		if [[ $dateTimeStart == "null" ]]; then
			startTime="\t\t"
		else
			startTime="$(date -d $dateTimeStart +'%H:%M') - $(date -d $dateTimeEnd +'%H:%M')\t"
		fi
		agenda+="\t$startTime$(getName "$meeting")\n"
	done

    printf "$agenda"
}