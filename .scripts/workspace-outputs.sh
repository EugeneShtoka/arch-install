#!/bin/zsh

source ~/.env

MONITOR_LAPTOP=eDP-1
CONF=~/.config/i3/workspace-outputs.conf

assign_workspaces() {
    local start=$1 end=$2 monitor=$3
    for i in $(seq $start $end); do
        echo "workspace $i output $monitor"
    done
}

# Active = connected AND currently on (has WxH+X+Y geometry; handles "primary" keyword)
active_external=$(xrandr | grep ' connected' | grep -v "^${MONITOR_LAPTOP} " | grep -E '[0-9]+x[0-9]+\+' | head -n 1 | awk '{print $1}')
laptop_active=$(xrandr | grep "^${MONITOR_LAPTOP} connected" | grep -E '[0-9]+x[0-9]+\+')

move_workspaces() {
    local start=$1 end=$2 monitor=$3
    for i in $(seq $start $end); do
        i3-msg "workspace $i; move workspace to output $monitor" 2>/dev/null
    done
}

if [[ -n "$active_external" && -n "$laptop_active" ]]; then
    # Combined: split workspaces across both monitors
    { assign_workspaces 1 3 $MONITOR_LAPTOP; assign_workspaces 4 10 $active_external } > $CONF
    i3-msg reload 2>/dev/null
    move_workspaces 1 3 $MONITOR_LAPTOP
    move_workspaces 4 10 $active_external
elif [[ -n "$active_external" ]]; then
    # External only (lid closed): all workspaces on external
    assign_workspaces 1 10 $active_external > $CONF
    i3-msg reload 2>/dev/null
    move_workspaces 1 10 $active_external
else
    # Laptop only: no explicit assignments needed
    > $CONF
    i3-msg reload 2>/dev/null
    move_workspaces 1 10 $MONITOR_LAPTOP
fi
