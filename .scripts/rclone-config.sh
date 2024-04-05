source $SCRIPTS_PATH/bw-unlock.sh
confPath=$HOME/.config/rclone

conf=$(bw get item rclone | jq '.notes')
conf="${conf//\\n/\n}"
conf="${conf//\\\"/\"}"

echo $conf > ~/.config/rclone/rclone.conf