#!/bin/zsh

USR_HOME=/home/eugene
SCRIPTS_PATH=$USR_HOME/.scripts
MONITOR_LAPTOP=eDP-1

# Small delay to let the monitor be recognized by xrandr
sleep 5

# Determine if running as root (udev) or as user (i3 startup)
if [[ "$EUID" -eq 0 ]]; then
    user="$(who -u | grep -F '(:0)' | head -n 1 | awk '{print $1}')"
    if [[ -z "$user" ]]; then
        echo "`date` monitor-setup-hook: No active X session user found" >> $USR_HOME/.scripts.log
        exit 1
    fi
    run_cmd() { su "$user" -c "DISPLAY=:0 $1"; }
else
    export DISPLAY=${DISPLAY:-:0}
    run_cmd() { eval "$1"; }
fi

external=$(run_cmd "xrandr" 2>/dev/null | grep ' connected' | grep -v "^${MONITOR_LAPTOP} " | head -n 1 | awk '{print $1}')

if [[ -n "$external" ]]; then
    lid_state=$(cat /proc/acpi/button/lid/LID0/state 2>/dev/null | awk '{print $2}')
    if [[ "$lid_state" == "open" ]]; then
        mode="dual"
    else
        mode="external"
    fi
else
    mode="laptop"
fi

echo "`date` monitor-setup-hook: detected mode=$mode" >> $USR_HOME/.scripts.log
run_cmd "$SCRIPTS_PATH/monitor-setup.sh $mode" >> $USR_HOME/.scripts.log 2>&1
