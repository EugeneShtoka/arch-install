#!/bin/zsh

if [ -z "$1" ]; then
     
    pathToPlay=$MUSIC_PATH/$choice
else
    choice=$(ls $MUSIC_PATH -a | rofi -theme ${dir}/${theme}.rasi -dmenu -matching prefix)
    echo $choice
    pathToPlay=$MUSIC_PATH/$choice
fi


setsid cvlc --random $pathToPlay > /dev/null 2>&1 &
