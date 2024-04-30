#!/bin/zsh
echo AAA $1
if [ -z "$1" ]; then
	dir="$HOME/.config/rofi/launchers/type-4"
	theme='style-9'
    choice=$(ls $MUSIC_PATH -a | rofi -theme ${dir}/${theme}.rasi -dmenu -matching prefix)
    echo $choice
    pathToPlay=$MUSIC_PATH/$choice
else
    pathToPlay=$MUSIC_PATH/$1
fi

echo $pathToPlay

#setsid cvlc --random $pathToPlay > /dev/null 2>&1 &
