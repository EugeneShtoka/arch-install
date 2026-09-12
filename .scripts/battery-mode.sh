#!/bin/zsh

CONF=/etc/tlp.conf
BAT=BAT0
SYS=/sys/class/power_supply/$BAT

# mode -> start stop
LONGEVITY_THRESH=(75 80)
MAXCHARGE_THRESH=(95 100)

read_thresh() {
    start=$(cat $SYS/charge_control_start_threshold 2>/dev/null)
    stop=$(cat $SYS/charge_control_end_threshold 2>/dev/null)
}

read_conf_thresh() {
    conf_start=$(grep -oP "^START_CHARGE_THRESH_$BAT=\K.*" $CONF 2>/dev/null)
    conf_stop=$(grep -oP "^STOP_CHARGE_THRESH_$BAT=\K.*" $CONF 2>/dev/null)
}

mode_name() {
    case "$1 $2" in
        "$LONGEVITY_THRESH[1] $LONGEVITY_THRESH[2]") echo "battery optimization" ;;
        "$MAXCHARGE_THRESH[1] $MAXCHARGE_THRESH[2]") echo "max charge" ;;
        *) echo "custom" ;;
    esac
}

show() {
    read_thresh
    read_conf_thresh
    local level=$(cat $SYS/capacity 2>/dev/null)
    local state=$(cat $SYS/status 2>/dev/null)

    echo "Battery : $level% ($state:l)"
    echo "Active  : charge $start-$stop%  [$(mode_name $start $stop)]"
    if [[ $conf_start != $start || $conf_stop != $stop ]]; then
        echo "Config  : charge $conf_start-$conf_stop%  [$(mode_name $conf_start $conf_stop)]  (differs - not applied)"
    else
        echo "Config  : persisted in $CONF"
    fi
}

set_mode() {
    local new_start=$1 new_stop=$2

    if ! grep -q "^START_CHARGE_THRESH_$BAT=" $CONF; then
        echo "Error: START_CHARGE_THRESH_$BAT not found in $CONF" >&2
        exit 1
    fi

    sudo cp -n $CONF $CONF.bak-battery-mode
    sudo sed -i \
        -e "s/^START_CHARGE_THRESH_$BAT=.*/START_CHARGE_THRESH_$BAT=$new_start/" \
        -e "s/^STOP_CHARGE_THRESH_$BAT=.*/STOP_CHARGE_THRESH_$BAT=$new_stop/" \
        $CONF || exit 1

    sudo tlp setcharge $BAT >/dev/null || exit 1

    echo "Set to [$(mode_name $new_start $new_stop)] - charge $new_start-$new_stop%"
    echo
    show
}

pick() {
    read_thresh
    echo "Current: $(cat $SYS/capacity)% - charge $start-$stop% [$(mode_name $start $stop)]"
    echo
    echo "  1) battery optimization   charge $LONGEVITY_THRESH[1]-$LONGEVITY_THRESH[2]%   (daily use, preserves battery health)"
    echo "  2) max charge             charge $MAXCHARGE_THRESH[1]-$MAXCHARGE_THRESH[2]%  (travel, longest runtime)"
    echo
    printf "Mode [1/2, Enter to keep current]: "
    read choice
    case $choice in
        1) set_mode $LONGEVITY_THRESH ;;
        2) set_mode $MAXCHARGE_THRESH ;;
        "") echo "Unchanged." ;;
        *) echo "Invalid choice." >&2; exit 1 ;;
    esac
}

case "$1" in
    longevity|optimization|opt|80) set_mode $LONGEVITY_THRESH ;;
    max|maxcharge|full|travel|100) set_mode $MAXCHARGE_THRESH ;;
    status|show)                   show ;;
    "")                            pick ;;
    *) echo "Usage: ${0:t} [longevity|max|status]" >&2; exit 1 ;;
esac
