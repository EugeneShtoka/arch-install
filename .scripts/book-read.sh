#!/bin/zsh
if [ -z "$1" ]; then
	dir="$HOME/.config/rofi/launchers/type-4"
	theme='style-9-columns'
    choice=$(ls $LIBRARY_PATH -a | grep -v '\.\.' | rofi -i -theme ${dir}/${theme}.rasi -dmenu -matching prefix)
    if [[ -n $choice ]]; then
        pathToRead=$LIBRARY_PATH/$choice
        setsid cvlc --random $pathToPlay > /dev/null 2>&1 &
    fi
else
    pathToPlay=$LIBRARY_PATH/$1
    setsid cvlc --random $pathToPlay > /dev/null 2>&1 &
fi
