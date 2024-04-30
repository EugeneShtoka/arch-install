#!/bin/zsh
echo AAA $1
if [ -z "$1" ]; then
    echo empty
    pathToPlay=$MUSIC_PATH/$choice
else
	dir="$HOME/.config/rofi/launchers/type-4"
	theme='style-9a'
    choice=$(ls $MUSIC_PATH -a | rofi -theme ${dir}/${theme}.rasi -dmenu -matching prefix)
    echo $choice
    pathToPlay=$MUSIC_PATH/$choice
fi


#setsid cvlc --random $pathToPlay > /dev/null 2>&1 &
