str=$(bw get item rclone | jq '.notes')
formatted_string="${str//\\n/\n}"
formatted_string="${formatted_string//\\\"/\"}"