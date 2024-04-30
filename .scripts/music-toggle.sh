#!/bin/zsh
pid=${ps aux | grep vlc | grep -v grep | awk '{print $2}'}
if [ -z "$pid" ]; then
	echo empty
else
    echo $pid
fi

setsid cvlc --random $pathToPlay > /dev/null 2>&1 &
