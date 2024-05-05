#!/bin/zsh

url=$1
mkdir ~/yt-temp
html_file=~/yt-temp/song.html
#wget $url -O $html_file

title=$(sed -n 's/.*<title>\(.*\)<\/title>.*/\1/p' "$html_file" | \
        grep -Eo '<title>.*</title>' | \
        sed -e 's/<[^>]*>//g')

echo $title
title="Manu Chao – Clandestino (Official Music Video)"
KEY=$(secret-tool lookup provider gemini key-pair secret)
echo $KEY
request=""
gmnUrl='https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key='$KEY
echo $gmnUrl
echo $request
contents='{"contents":[{"parts":[{"text":"From title get artist and song: '$title', return result as json"}]}]}'
echo $contents
respose=$(curl -H 'Content-Type: application/json' -d $cotents -X POST $gmnUrl)
echo $respose
#yt-dlp -x --audio-format mp3 $url -o Music/$author/$song.mp3
##id3v2 -a $author Music/$author/$song.mp3
