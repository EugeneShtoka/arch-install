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

# Move existing workspaces to their assigned outputs, then restore focus.
# Args: pairs of "start end monitor" passed as: move_workspaces "1 3 DP-2" "4 10 eDP-1" ...
move_all_workspaces() {
    local focused
    focused=$(i3-msg -t get_workspaces | jq -r '.[] | select(.focused) | .name')
    local existing
    existing=$(i3-msg -t get_workspaces | jq -r '.[].name')

    for spec in "$@"; do
        local start end monitor
        start=${spec%% *}; rest=${spec#* }; end=${rest%% *}; monitor=${rest#* }
        for i in $(seq $start $end); do
            echo "$existing" | grep -qx "$i" || continue
            i3-msg "workspace $i; move workspace to output $monitor" 2>/dev/null
        done
    done

    [[ -n "$focused" ]] && i3-msg "workspace $focused" 2>/dev/null
}

if [[ -n "$active_external" && -n "$laptop_active" ]]; then
    # Combined: split workspaces across both monitors
    { assign_workspaces 1 3 $MONITOR_LAPTOP; assign_workspaces 4 10 $active_external } > $CONF
    i3-msg reload 2>/dev/null
    move_all_workspaces "1 3 $MONITOR_LAPTOP" "4 10 $active_external"
elif [[ -n "$active_external" ]]; then
    # External only (lid closed): all workspaces on external
    assign_workspaces 1 10 $active_external > $CONF
    i3-msg reload 2>/dev/null
    move_all_workspaces "1 10 $active_external"
else
    # Laptop only: no explicit assignments needed
    > $CONF
    i3-msg reload 2>/dev/null
    move_all_workspaces "1 10 $MONITOR_LAPTOP"
fi

pkill dunst; dunst &
