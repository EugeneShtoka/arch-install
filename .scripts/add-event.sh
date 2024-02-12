GEMINI_API_KEY=$(bw get item 'Gemini API Key' | jq '.notes' |  tr -d \")

CONTENT="Translate $1 to english"

echo $CONTENT

curl https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$GEMINI_API_KEY \
    -H 'Content-Type: application/json' \
    -X POST \
    -d '{
      "contents": [{
        "parts":[{
          "text": "Translate ${CONTENT} to english"}]}]}' 2> /dev/null | jq '.candidates[].content.parts[].text' | tr -d \"