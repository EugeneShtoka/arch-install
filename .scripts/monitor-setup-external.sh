#!/bin/zsh

source /home/eugene/.env

MONITOR_LAPTOP=eDP-1
MONITOR_EXTERNAL=$(xrandr | grep ' connected' | grep -v "^${MONITOR_LAPTOP} " | head -n 1 | awk '{print $1}')

if [[ -z "$MONITOR_EXTERNAL" ]]; then
    echo "`date` monitor-setup-external: no external monitor found" >> $LOG_PATH
    exit 0
fi

echo "`date` connecting monitor $MONITOR_EXTERNAL" >> $LOG_PATH
xrandr --output $MONITOR_EXTERNAL --mode 3840x2160 --rate 120 --primary

# Turn off any other outputs (e.g. leftover HDMI config when switching to DP)
for monitor in $(xrandr | grep -v "^${MONITOR_LAPTOP} " | grep -v "^${MONITOR_EXTERNAL} " | grep -E ' connected| disconnected' | awk '{print $1}'); do
    xrandr --output $monitor --off
done

lid_state=$(cat /proc/acpi/button/lid/LID0/state 2>/dev/null | awk '{print $2}')
if [[ "$lid_state" == "open" ]]; then
    echo "`date` lid open, placing $MONITOR_LAPTOP to the right of $MONITOR_EXTERNAL" >> $LOG_PATH
    xrandr --output $MONITOR_LAPTOP --auto --right-of $MONITOR_EXTERNAL
else
    echo "`date` lid closed, disabling $MONITOR_LAPTOP" >> $LOG_PATH
    xrandr --output $MONITOR_LAPTOP --off
fi

$SCRIPTS_PATH/workspace-outputs.sh
