#!/bin/zsh

source $SCRIPTS_PATH/bw-unlock.sh

confPath=$HOME/.config/rclone
mkdir -p $confPath

str=$(bw get item rclone | jq '.notes')
echo $str
conf="${str//\\n/\n}"
echo $conf
conf="${conf//\\\"/\"}"
echo $conf

echo $conf > $confPath/rclone.conf