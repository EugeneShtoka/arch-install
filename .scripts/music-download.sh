#!/bin/zsh

url=$1
mkdir ~/yt-temp
wget $url -O ~/yt-temp/song.html

author=$1
song=$2
url=$3
yt-dlp -x --audio-format mp3 $url -o Music/$author/$song.mp3
id3v2 -a $author Music/$author/$song.mp3