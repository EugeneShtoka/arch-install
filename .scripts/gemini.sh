#!/bin/zsh

function gemini-cli-wrapper() {
    PROMPT="$1"
    KEY=$(secret-tool lookup provider gemini key-pair secret)
    gemini-cli --key "$KEY" prompt "$PROMPT"
}
