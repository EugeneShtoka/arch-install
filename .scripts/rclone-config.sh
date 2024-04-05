source $SCRIPTS_PATH/bw-unlock.sh

str=$(bw get item rclone | jq '.notes')
formatted_string="${str//\\n/\n}"
formatted_string="${formatted_string//\\\"/\"}"