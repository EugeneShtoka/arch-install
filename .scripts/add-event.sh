GEMINI_API_KEY=$(bw get item 'Gemini API Key' | jq '.notes' |  tr -d \")

CONTENT="Translate $1 to english"

BODY='{"contents": [{"parts":[{"text": $CONTENT}]}]}'

echo $BODY

curl https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$GEMINI_API_KEY \
    -H 'Content-Type: application/json' \
    -X POST \
    -d "$BODY" 2> /dev/null