source $SCRIPTS_PATH/bw-unlock.sh

confPath=$HOME/.config/rclone
mldir -p $confPath

conf=$(bw get item rclone | jq '.notes')
conf="${conf//\\n/\n}"
conf="${conf//\\\"/\"}"

echo $conf > $confPath/rclone.conf