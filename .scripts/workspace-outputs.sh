#!/bin/zsh

source ~/.env

MONITOR_LAPTOP=eDP-1
CONF=~/.config/i3/workspace-outputs.conf

external=$(xrandr | grep ' connected' | grep -v "^${MONITOR_LAPTOP} " | head -n 1 | awk '{print $1}')

if [[ -n "$external" ]]; then
    cat > $CONF <<EOF
workspace $ws1 output $MONITOR_LAPTOP
workspace $ws2 output $MONITOR_LAPTOP
workspace $ws3 output $MONITOR_LAPTOP
workspace $ws4 output $external
workspace $ws5 output $external
workspace $ws6 output $external
workspace $ws7 output $external
workspace $ws8 output $external
workspace $ws9 output $external
workspace $ws10 output $external
EOF
else
    > $CONF
fi

i3-msg reload
