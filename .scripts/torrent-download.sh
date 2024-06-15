#!/bin/zsh

dir="$HOME/.config/rofi/launchers/type-4"
theme='style-9-columns'
choice=$(ls $DOWNLOAD_DIR | grep '.torrent' | rofi -i -theme ${dir}/${theme}.rasi -dmenu -matching prefix)

if [[ -n $choice ]]; then
    torrentPath=$DOWNLOAD_DIR/"$choice"
    name=$choice #convert to more meaningful name with gemini
    setsid $(transmission-cli "$torrentPath" -w Torrents > .trnts/"$name".log) > /dev/null 2>&1 &
fi