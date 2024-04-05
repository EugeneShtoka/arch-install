source $SCRIPTS_PATH/bw-unlock.sh

confPath=$HOME/.config/rclone
mkdir -p $confPath

conf=$(bw get item rclone | jq '.notes')
echo $conf
conf="${conf//\\n/\n}"
echo $conf
conf="${conf//\\\"/\"}"
echo $conf

echo $conf > $confPath/rclone.conf