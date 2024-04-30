#!/bin/zsh

if [ -z "$1" ]; then
    PLAY_PATH=
else
    PLAY_PATH=$MUSIC_PATH/$1
fi

setsid cvlc --random $PLAY_PATH > /dev/null 2>&1 &
