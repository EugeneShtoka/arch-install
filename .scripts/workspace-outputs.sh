#!/bin/zsh

source ~/.env

MONITOR_LAPTOP=eDP-1
CONF=~/.config/i3/workspace-outputs.conf

external=$(xrandr | grep ' connected' | grep -v "^${MONITOR_LAPTOP} " | head -n 1 | awk '{print $1}')

# Always write set definitions — values come from .env, i3 var names are literal (\$wsN)
cat > $CONF <<EOF
set \$ws1  $ws1
set \$ws2  $ws2
set \$ws3  $ws3
set \$ws4  $ws4
set \$ws5  $ws5
set \$ws6  $ws6
set \$ws7  $ws7
set \$ws8  $ws8
set \$ws9  $ws9
set \$ws10 $ws10
EOF

if [[ -n "$external" ]]; then
    cat >> $CONF <<EOF
workspace \$ws1 output $MONITOR_LAPTOP
workspace \$ws2 output $MONITOR_LAPTOP
workspace \$ws3 output $MONITOR_LAPTOP
workspace \$ws4 output $external
workspace \$ws5 output $external
workspace \$ws6 output $external
workspace \$ws7 output $external
workspace \$ws8 output $external
workspace \$ws9 output $external
workspace \$ws10 output $external
EOF
fi

i3-msg reload 2>/dev/null
