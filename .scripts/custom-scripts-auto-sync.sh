#!/bin/zsh

$SCRIPTS_PATH/custom-scripts-pull.sh

echo "`date` custom-scripts-auto-sync" >> $LOG_PATH

on_change() {
    local dir=$1 event=$2 file=$3
    echo "`date` custom-scripts-auto-sync $event on $dir$file" >> $LOG_PATH
    if [[ "$dir" == "/etc/udev/rules.d/" && -n "$file" ]]; then
        cp "$dir$file" $SCRIPTS_PATH/udev-rules/ 2>/dev/null
    fi
    $SCRIPTS_PATH/custom-scripts-push.sh
}

# Flat dirs (no subdirs to recurse) and single files
FLAT=(
    $HOME/.zshrc $HOME/.env $HOME/.gitignore $HOME/.xprofile $HOME/.gitconfig
    $SCRIPTS_PATH $HOME/.scripts/udev-rules
    $HOME/.icons $HOME/.sounds $HOME/.zshfn
    $HOME/.config/systemd/user $SERVICES_PATH
    $HOME/.config/vivaldi $HOME/.config/vivaldi/styles $HOME/.config/vivaldi/uBlock-filters
    $HOME/.config/xdg-desktop-portal
    /etc/udev/rules.d
)

# Dirs with nested subdirs - watched recursively
RECURSIVE=(
    $HOME/.config/i3
    $HOME/.config/nvim $HOME/.config/wezterm $HOME/.config/yazi
    $HOME/.config/iamb $HOME/.config/neomutt $HOME/.config/notmuch
    $HOME/.config/goimapnotify $HOME/.config/rofi $HOME/.config/copyq
    $HOME/.config/dunst $HOME/.config/fontconfig $HOME/.config/gtk-3.0
    $HOME/.config/zenity-cobalt2 $HOME/.config/qBittorrent $HOME/.config/rimworld
    $HOME/.config/xdg-desktop-portal-termfilechooser
)

inotifywait -q -m -e DELETE,CLOSE_WRITE,MOVED_TO,MOVED_FROM $FLAT | while read dir event file; do
    on_change $dir $event $file
done &

inotifywait -q -m -r -e DELETE,CLOSE_WRITE,MOVED_TO,MOVED_FROM $RECURSIVE | while read dir event file; do
    on_change $dir $event $file
done &

wait
