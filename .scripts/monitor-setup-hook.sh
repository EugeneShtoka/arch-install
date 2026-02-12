#!/bin/zsh

USR_HOME=/home/eugene
source $USR_HOME/.env

mode="$1"
user="$(who -u | grep -F '(:0)' | head -n 1 | awk '{print $1}')"
su -c "DISPLAY=:0.0 zsh -x $SCRIPTS_PATH/monitor-setup-$mode.sh" "$user"
# mode: "external" (monitor connected) or "laptop" (monitor disconnected)

