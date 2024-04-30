#!/bin/zsh
pid=$(ps aux | grep vlc | grep -v grep | awk '{print $2}')
if [ -z "$pid" ]; then
	SCRIPTS_PATH/music-play.sh
else
    echo $pid
fi

#setsid cvlc --random $pathToPlay > /dev/null 2>&1 &
