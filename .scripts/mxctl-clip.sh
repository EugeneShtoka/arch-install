#!/bin/zsh
# mxctl-clip.sh — clipboard processor for mxctl
# stdin:  JSON {"event_id","room_id","room_name","sender","body","msg_type","ts"}
# stdout: JSON action, or nothing if nothing actionable found

body=$(jq -r '.body // empty')
[[ -z "$body" ]] && exit 0

# OTP/code: keyword-prefixed (higher priority, more specific)
code=$(printf '%s' "$body" | grep -oP '(?i)(?:code|otp|pin|token|passcode)\D*\K\d{4,8}' | head -1)

# Standalone 4–8 digit number not part of a longer number or URL path
if [[ -z "$code" ]]; then
    code=$(printf '%s' "$body" | grep -oP '(?<![/.\d])\d{4,8}(?![/.\d])' | head -1)
fi

# URL
url=$(printf '%s' "$body" | grep -oP 'https?://[^\s<>"]+' | head -1)

if [[ -n "$code" ]]; then
    jq -n --arg val "$code" \
        '{"type":"clipboard+notify","value":$val,"title":"[mxctl] Copied to clipboard","body":("Code copied: "+$val)}'
elif [[ -n "$url" ]]; then
    short=$(printf '%s' "$url" | head -c 60)
    [[ "${#url}" -gt 60 ]] && short="${short}…"
    jq -n --arg val "$url" --arg b "Link copied: $short" \
        '{"type":"clipboard+notify","value":$val,"title":"[mxctl] Copied to clipboard","body":$b}'
fi
