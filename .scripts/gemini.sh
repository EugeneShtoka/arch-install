PROMPT=$1
KEY=$(secret-tool lookup provider gemini key-pair secret)
resJson=$(gemini-cli --key $KEY prompt "From title get artist and song: '$title', json response, resonse in single line")