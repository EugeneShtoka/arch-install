#!/bin/zsh

for file in $MUSIC_PATH/**/*; do
    str=$(file $file)
    parts=(${(s/,/)str})
    echo $parts[1] $parts[5]
done

author=$1
song=$2
url=$3
yt-dlp -x --audio-format mp3 $url -o Music/$author/$song.mp3