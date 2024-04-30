#!/bin/zsh

if [ -z "$1" ]; then
    pathToPlay=$MUSIC_PATH/$choice
else
    pathToPlay=$MUSIC_PATH/$1
fi

setsid cvlc --random $pathToPlay > /dev/null 2>&1 &
