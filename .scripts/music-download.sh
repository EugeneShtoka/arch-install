#!/bin/zsh

url=$1
mkdir ~/yt-temp
wget $url -O ~/yt-temp/song.html

title=$(sed -n 's/.*<title>\(.*\)<\/title>.*/\1/p' "$html_file" | \
        grep -Eo '<title>.*</title>' | \
        sed -e 's/<[^>]*>//g')

parseWithGemini=$(gemini 'From title get artist and song "$title", return result as json')

KEY=$(secret-tool lookup provider gemini key-pair secret)
respose=$(curl -H 'Content-Type: application/json' -d '{"contents":[{"parts":[{"text":"From title get artist and song: $title, return result as json"}]}]}' -X POST 'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$KEY')
echo $respose
#yt-dlp -x --audio-format mp3 $url -o Music/$author/$song.mp3
##id3v2 -a $author Music/$author/$song.mp3
