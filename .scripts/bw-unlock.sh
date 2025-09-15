#!/bin/zsh

# Try fingerprint unlock first, fallback to original method
if [[ -x "$HOME/.scripts/bw-fingerprint-unlock.sh" ]]; then
    # Use fingerprint unlock
    source <($HOME/.scripts/bw-fingerprint-unlock.sh 2>/dev/null && cat $HOME/.config/bw-session 2>/dev/null)
else
    # Fallback to original password method
    bw_status=$(bw status | jq '.status' | tr -d \")
    if [[ "$bw_status" == "locked" ]]; then
        export BW_SESSION=$(bw unlock | grep '$ export' | awk -F'BW_SESSION=' '{print $2}')
    fi
fi