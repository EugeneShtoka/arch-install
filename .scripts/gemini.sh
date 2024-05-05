
gemini() {
    PROMPT="$1"
    KEY=$(secret-tool lookup provider gemini key-pair secret)
    echo "$(gemini-cli --key $KEY prompt $PROMPT)"
}