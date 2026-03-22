# Returns the dunst monitor index: external (DP-*) if connected, internal (eDP-*) otherwise
get_notify_monitor() {
    xrandr --listmonitors | awk '
        /DP-/ { ext_idx = $1+0; found_ext = 1 }
        /eDP-/ { int_idx = $1+0 }
        END { print (found_ext ? ext_idx : int_idx) }
    '
}

# Drop-in wrapper for notify-send that targets the correct monitor
notify_send() {
    local monitor=$(get_notify_monitor)
    notify-send -h "int:x-dunst-monitor:$monitor" "$@"
}
