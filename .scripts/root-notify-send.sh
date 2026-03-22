function root-notify-send() {
    #Detect the name of the display in use
    local display=":$(ls /tmp/.X11-unix/* | sed 's#/tmp/.X11-unix/X##' | head -n 1)"

    #Detect the user using such display
    local user=$(who | grep '('$display')' | awk '{print $1}' | head -n 1)

    #Detect the id of the user
    local uid=$(id -u $user)

    local monitor=$(sudo -u $user DISPLAY=$display xrandr --listmonitors | awk '
        /DP-/ { ext_idx = $1+0; found_ext = 1 }
        /eDP-/ { int_idx = $1+0 }
        END { print (found_ext ? ext_idx : int_idx) }
    ')

    sudo -u $user DISPLAY=$display DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$uid/bus notify-send -h "int:x-dunst-monitor:$monitor" "$@"
}