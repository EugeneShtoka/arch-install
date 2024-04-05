source $SCRIPTS_PATH/bw-unlock.sh

conf=$(bw get item rclone | jq '.notes')
conf="${conf//\\n/\n}"
conf="${conf//\\\"/\"}"

echo $conf > ~/.config/rclone/rclone.conf