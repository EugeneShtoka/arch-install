#!/bin/zsh

playlist_extension="xspf"
if [ -z "$1" ]; then
	dir="$HOME/.config/rofi/launchers/type-4"
	theme='style-9-wide'
    choice=$(find "$MUSIC_PATH" -type f -name "*.xspf" -printf "%f\n" | sed "s/\.xspf$//" | rofi -i -theme ${dir}/${theme}.rasi -dmenu -matching prefix)
    if [[ -n $choice ]]; then
        pathToPlay="$MUSIC_PATH/$choice.xspf"
        setsid cvlc --random $pathToPlay > /dev/null 2>&1 &
    fi
else
    pathToPlay=$MUSIC_PATH/$1
    setsid cvlc --random $pathToPlay > /dev/null 2>&1 &
fi


