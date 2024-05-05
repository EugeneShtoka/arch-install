#!/bin/zsh

url=$(xclip -o -selection c)
mkdir ~/yt-temp
html_file=~/yt-temp/song.html
wget $url -O $html_file

html=`cat $html_file`
parts=(${(s/title>/)html})
titleRaw=${parts[2]}
title=${titleRaw::-2}

if [[ -n $title ]]; then
    KEY=$(secret-tool lookup provider gemini key-pair secret)
    resJson=$(gemini-cli --key $KEY prompt "From title get artist and song: '$title', json response, resonse in single line")
    echo $resJson
    if [[ -n $resJson ]]; then
        echo $resJson
        artist=$(echo $(echo $resJson | jq 'fromjson | .artist' | tr -d '"'))
        song=$(echo $(echo $resJson | jq 'fromjson | .song' | tr -d '"'))
        if [[ -n $artist && -n $song ]]; then
            yt-dlp -x --audio-format mp3 $url -o Music/$artist/$song.mp3
            id3v2 -a $artist Music/$artist/$song.mp3
            notify-send "YouTube Download" "Track saved to Music/$artist/$song.mp3"
        fi
    fi
fi
