#!/bin/zsh

source /home/eugene/.env

MONITOR_LAPTOP=eDP-1
MODE=$1
RUN_DIR=/run/user/$(id -u)
# Connected outputs as of the last applied layout; lets hotplug bursts skip re-applying
STATE_FILE=$RUN_DIR/monitor-setup.state

if [[ -z "$MODE" ]]; then
    echo "Usage: monitor-setup.sh <external|laptop|dual|auto [--if-changed]>" >&2
    exit 1
fi

# udev fires several events per plug; serialize runs with each other and the rofi menu
exec {lock_fd}>$RUN_DIR/monitor-setup.lock
flock $lock_fd

XRANDR=$(xrandr)
connected=$(awk '$2=="connected"{print $1}' <<< "$XRANDR" | sort | paste -sd' ')
all_outputs=($(awk '$2=="connected" || $2=="disconnected"{print $1}' <<< "$XRANDR"))
MONITOR_EXTERNAL=$(awk -v l=$MONITOR_LAPTOP '$2=="connected" && $1!=l{print $1; exit}' <<< "$XRANDR")

if [[ "$MODE" == "auto" ]]; then
    # Hotplug: only act when the set of connected outputs changed, so a layout
    # forced from the menu isn't overridden by a late duplicate event
    if [[ "$2" == "--if-changed" && "$connected" == "$(cat $STATE_FILE 2>/dev/null)" ]]; then
        echo "`date` monitor-setup: auto, outputs unchanged ($connected), skipping" >> $LOG_PATH
        exit 0
    fi
    if [[ -z "$MONITOR_EXTERNAL" ]]; then
        MODE=laptop
    elif [[ "$(awk '{print $2}' /proc/acpi/button/lid/LID0/state 2>/dev/null)" == "open" ]]; then
        MODE=dual
    else
        MODE=external
    fi
    echo "`date` monitor-setup: auto detected mode=$MODE" >> $LOG_PATH
fi

# 4K@120 when the monitor offers it, otherwise its preferred mode
external_mode() {
    if awk -v o=$1 '$1==o{f=1;next} /^[^ ]/{f=0} f && $1=="3840x2160" && / 1(19\.9|20\.0)/' <<< "$XRANDR" | grep -q .; then
        echo "--mode 3840x2160 --rate 120"
    else
        echo "--auto"
    fi
}

case $MODE in
    external|dual)
        if [[ -z "$MONITOR_EXTERNAL" ]]; then
            echo "`date` monitor-setup: no external monitor found, falling back to laptop" >> $LOG_PATH
            MODE=laptop
        fi
        ;;
    laptop) ;;
    *)
        echo "monitor-setup: unknown mode '$MODE'" >&2
        exit 1
        ;;
esac

case $MODE in
    external)
        echo "`date` monitor-setup: external-only ($MONITOR_EXTERNAL)" >> $LOG_PATH
        targets=($MONITOR_EXTERNAL)
        args=(--output $MONITOR_EXTERNAL ${=$(external_mode $MONITOR_EXTERNAL)} --pos 0x0 --primary)
        ;;
    dual)
        echo "`date` monitor-setup: dual ($MONITOR_EXTERNAL + $MONITOR_LAPTOP)" >> $LOG_PATH
        targets=($MONITOR_EXTERNAL $MONITOR_LAPTOP)
        args=(--output $MONITOR_EXTERNAL ${=$(external_mode $MONITOR_EXTERNAL)} --pos 0x0 --primary
              --output $MONITOR_LAPTOP --auto --right-of $MONITOR_EXTERNAL)
        ;;
    laptop)
        echo "`date` monitor-setup: laptop-only" >> $LOG_PATH
        targets=($MONITOR_LAPTOP)
        args=(--output $MONITOR_LAPTOP --auto --pos 0x0 --primary)
        ;;
esac

# Turn off every other output, including ones unplugged while still enabled:
# they show as "disconnected" but keep their CRTC (and primary) until turned off
for mon in $all_outputs; do
    (( ${targets[(Ie)$mon]} )) && continue
    args+=(--output $mon --off)
done

# One call, so there are no half-applied intermediate layouts
if ! xrandr $args >> $LOG_PATH 2>&1; then
    echo "`date` monitor-setup: xrandr $args failed" >> $LOG_PATH
    # e.g. the monitor rejects the mode: never leave both screens dark
    if [[ "$MODE" != laptop ]]; then
        exec {lock_fd}>&-
        exec $SCRIPTS_PATH/monitor-setup.sh laptop
    fi
    exit 1
fi
echo "$connected" > $STATE_FILE

# Wait (up to 2s) for i3 to pick up the new outputs before moving workspaces onto them
want=${(j: :)${(o)targets}}
for i in {1..20}; do
    [[ "$(i3-msg -t get_outputs 2>/dev/null | jq -r '[.[] | select(.active) | .name] | sort | join(" ")')" == "$want" ]] && break
    sleep 0.1
done

# Close the lock fd: workspace-outputs.sh restarts dunst, which would otherwise hold the lock forever
$SCRIPTS_PATH/workspace-outputs.sh {lock_fd}>&-
