#!/bin/zsh

setsid cvlc --random $1 > /dev/null 2>&1 &
