#!/bin/zsh

url=$1
mkdir ~/yt-temp
html_file=~/yt-temp/song.html
#wget $url -O $html_file

title=$(sed 's/.*<title>"\([0-9]*\)".*/\1/g' $html_file)

echo $title
title="Manu Chao – Clandestino (Official Music Video)"
# KEY=$(secret-tool lookup provider gemini key-pair secret)
# echo $KEY
# request=""
# gmnUrl='https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key='$KEY
# echo $gmnUrl
# echo $request
# contents='{"contents":[{"parts":[{"text":"From title get artist and song: '$title', json response, resonse in single line"}]}]}'
# respose=$(curl -H 'Content-Type: application/json' -d $contents -X POST $gmnUrl)
# resJson=$(echo $respose | jq '.candidates[0].content.parts[0].text')
# artist=$(echo $(echo $resJson | jq 'fromjson | .artist'))
# song=$(echo $(echo $resJson | jq 'fromjson | .song'))
# yt-dlp -x --audio-format mp3 $url -o Music/$author/$song.mp3
# id3v2 -a $author Music/$author/$song.mp3
