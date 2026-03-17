#!/bin/zsh

source ~/.env

MONITOR_LAPTOP=eDP-1
CONF=~/.config/i3/workspace-outputs.conf

assign_workspaces() {
    local start=$1 end=$2 monitor=$3
    for i in $(seq $start $end); do
        varname="ws$i"
        echo "workspace \$ws$i output $monitor"
    done
}

# Active = connected AND currently on (has a resolution in xrandr output)
active_external=$(xrandr | grep ' connected [0-9]' | grep -v "^${MONITOR_LAPTOP} " | head -n 1 | awk '{print $1}')
laptop_active=$(xrandr | grep "^${MONITOR_LAPTOP} connected [0-9]")

if [[ -n "$active_external" && -n "$laptop_active" ]]; then
    # Combined: split workspaces across both monitors
    { assign_workspaces 1 3 $MONITOR_LAPTOP; assign_workspaces 4 10 $active_external } > $CONF
elif [[ -n "$active_external" ]]; then
    # External only (lid closed): all workspaces on external
    assign_workspaces 1 10 $active_external > $CONF
else
    # Laptop only: no explicit assignments needed
    > $CONF
fi

i3-msg reload 2>/dev/null
