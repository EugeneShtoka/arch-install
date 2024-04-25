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