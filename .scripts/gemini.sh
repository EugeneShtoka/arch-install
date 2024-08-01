#!/bin/zsh

gemini() {
    PROMPT="$1"
    KEY=$(secret-tool lookup provider gemini key-pair secret)
    gemini-cli --key $KEY prompt "$PROMPT"
}
