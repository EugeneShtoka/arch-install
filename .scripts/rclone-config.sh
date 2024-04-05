#!/bin/zsh

source $SCRIPTS_PATH/bw-unlock.sh

confPath=$HOME/.config/rclone
mkdir -p $confPath

str=$(bw get item rclone | jq '.notes')
conf="${str:1:-1}"
conf="${str//\\n/\n}"
conf="${conf//\\\"/\"}"

echo $conf > $confPath/rclone.conf