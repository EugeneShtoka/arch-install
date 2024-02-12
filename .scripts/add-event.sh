GEMINI_API_KEY=$(bw get item 'Gemini API Key' | jq '.notes' |  tr -d \")

BODY='{"contents": [{"parts":[{"text": "Translate '$1' to english, analyze for expected finish time and prepare json consisting of tile, location, startDate YYYY-MM-DDTHH:MM:SSZ, endDate YYYY-MM-DDTHH:MM:SSZ. Return json only"}]}],
"generationConfig": {
            "stopSequences": [
                "Title"
            ],
            "temperature": 0.2,
            "maxOutputTokens": 800,
            "topP": 1,
            "topK": 10
        }}'

curl https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$GEMINI_API_KEY \
    -H 'Content-Type: application/json' \
    -X POST \
    -d "$BODY" 2> /dev/null | jq '.candidates[].content.parts[0].text' | jq 'fromjson'