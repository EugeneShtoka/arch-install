#!/bin/zsh

source /home/eugene/.env

MONITOR_LAPTOP=eDP-1
MODE=$1

if [[ -z "$MODE" ]]; then
    echo "Usage: monitor-setup.sh <external|laptop|dual>" >&2
    exit 1
fi

MONITOR_EXTERNAL=$(xrandr | grep ' connected' | grep -v "^${MONITOR_LAPTOP} " | head -n 1 | awk '{print $1}')

case $MODE in
    external)
        if [[ -z "$MONITOR_EXTERNAL" ]]; then
            echo "`date` monitor-setup: no external monitor found, falling back to laptop" >> $LOG_PATH
            MODE=laptop
        else
            echo "`date` monitor-setup: external-only ($MONITOR_EXTERNAL)" >> $LOG_PATH
            xrandr --output $MONITOR_EXTERNAL --mode 3840x2160 --rate 120 --primary
            xrandr --output $MONITOR_LAPTOP --off
            for mon in $(xrandr | grep ' connected' | grep -v "^${MONITOR_LAPTOP} " | grep -v "^${MONITOR_EXTERNAL} " | awk '{print $1}'); do
                xrandr --output $mon --off
            done
        fi
        ;;
    dual)
        if [[ -z "$MONITOR_EXTERNAL" ]]; then
            echo "`date` monitor-setup: no external monitor found, falling back to laptop" >> $LOG_PATH
            MODE=laptop
        else
            echo "`date` monitor-setup: dual ($MONITOR_EXTERNAL + $MONITOR_LAPTOP)" >> $LOG_PATH
            xrandr --output $MONITOR_EXTERNAL --mode 3840x2160 --rate 120 --primary
            xrandr --output $MONITOR_LAPTOP --auto --right-of $MONITOR_EXTERNAL
        fi
        ;;
    laptop)
        ;;
    *)
        echo "monitor-setup: unknown mode '$MODE'" >&2
        exit 1
        ;;
esac

if [[ "$MODE" == "laptop" ]]; then
    echo "`date` monitor-setup: laptop-only" >> $LOG_PATH
    xrandr --output $MONITOR_LAPTOP --auto
    for mon in $(xrandr | grep ' connected' | grep -v "^${MONITOR_LAPTOP} " | awk '{print $1}'); do
        echo "`date` monitor-setup: disabling $mon" >> $LOG_PATH
        xrandr --output $mon --off
    done
fi

$SCRIPTS_PATH/workspace-outputs.sh
