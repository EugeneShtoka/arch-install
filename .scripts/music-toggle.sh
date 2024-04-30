#!/bin/zsh
pid=${ps aux | grep vlc | grep -v grep | awk '{print $2}'}
if [ -z "$1" ]; then
	dir="$HOME/.config/rofi/launchers/type-4"
	theme='style-9'
    choice=$(ls $MUSIC_PATH -a | rofi -i -theme ${dir}/${theme}.rasi -dmenu -matching prefix)
    pathToPlay=$MUSIC_PATH/$choice
else
    pathToPlay=$MUSIC_PATH/$1
fi

setsid cvlc --random $pathToPlay > /dev/null 2>&1 &
