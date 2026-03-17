#!/bin/zsh

source ~/.env

MONITOR_LAPTOP=eDP-1
CONF=~/.config/i3/workspace-outputs.conf

# Active = connected AND currently on (has a resolution in xrandr output)
active_external=$(xrandr | grep ' connected [0-9]' | grep -v "^${MONITOR_LAPTOP} " | head -n 1 | awk '{print $1}')
laptop_active=$(xrandr | grep "^${MONITOR_LAPTOP} connected [0-9]")

if [[ -n "$active_external" && -n "$laptop_active" ]]; then
    # Combined: split workspaces across both monitors
    cat > $CONF <<EOF
workspace \$ws1 output $MONITOR_LAPTOP
workspace \$ws2 output $MONITOR_LAPTOP
workspace \$ws3 output $MONITOR_LAPTOP
workspace \$ws4 output $active_external
workspace \$ws5 output $active_external
workspace \$ws6 output $active_external
workspace \$ws7 output $active_external
workspace \$ws8 output $active_external
workspace \$ws9 output $active_external
workspace \$ws10 output $active_external
EOF
elif [[ -n "$active_external" ]]; then
    # External only (lid closed): all workspaces on external
    cat > $CONF <<EOF
workspace \$ws1 output $active_external
workspace \$ws2 output $active_external
workspace \$ws3 output $active_external
workspace \$ws4 output $active_external
workspace \$ws5 output $active_external
workspace \$ws6 output $active_external
workspace \$ws7 output $active_external
workspace \$ws8 output $active_external
workspace \$ws9 output $active_external
workspace \$ws10 output $active_external
EOF
else
    # Laptop only: no explicit assignments needed
    > $CONF
fi

i3-msg reload 2>/dev/null
