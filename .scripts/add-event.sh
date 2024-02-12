GEMINI_API_KEY=$(bw get item 'Gemini API Key' | jq '.notes' |  tr -d \")

BODY='{"contents": [{"parts":[{"text": "Translate '$1' to english and convert to following format DTSTART;TZID=Asia/Jerusalem:
DTEND;TZID=Asia/Jerusalem:
SUMMARY:
LOCATION:"}]}]}'

curl https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$GEMINI_API_KEY \
    -H 'Content-Type: application/json' \
    -X POST \
    -d "$BODY" 2> /dev/null | jq