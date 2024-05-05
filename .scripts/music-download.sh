#!/bin/zsh

url=$1
mkdir ~/yt-temp
html_file=~/yt-temp/song.html
wget $url -O $html_file

html=`cat $html_file`
parts=(${(s/title>/)html})
titleRaw=${parts[2]}
title=${titleRaw::-2}

echo AAAAAAAAAA$title
KEY=$(secret-tool lookup provider gemini key-pair secret)
echo $KEY
gmnUrl='https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key='$KEY
echo $gmnUrl
contents=\''{"contents":[{"parts":[{"text":"From title get artist and song: '$title', json response, resonse in single line"}]}]}'\'
curl -H 'Content-Type: application/json' -d $contents -X POST $gmnUrl
response=$(curl -H 'Content-Type: application/json' -d $contents -X POST $gmnUrl)
echo BBBBBBBBBB$response
# resJson=$(echo $respose | jq '.candidates[0].content.parts[0].text')
# artist=$(echo $(echo $resJson | jq 'fromjson | .artist'))
# song=$(echo $(echo $resJson | jq 'fromjson | .song'))
# yt-dlp -x --audio-format mp3 $url -o Music/$author/$song.mp3
# id3v2 -a $author Music/$author/$song.mp3
