#!/bin/zsh

# mode: "external" (monitor connected) or "laptop" (monitor disconnected)
mode="$1"

USR_HOME=/home/eugene
SCRIPTS_PATH=$USR_HOME/.scripts

user="$(who -u | grep -F '(:0)' | head -n 1 | awk '{print $1}')"

if [[ -z "$user" ]]; then
    echo "`date` monitor-setup-hook: No active X session user found" >> $USR_HOME/.scripts.log
    exit 1
fi

su "$user" -c "DISPLAY=:0 $SCRIPTS_PATH/monitor-setup-$mode.sh" >> $USR_HOME/.scripts.log 2>&1

