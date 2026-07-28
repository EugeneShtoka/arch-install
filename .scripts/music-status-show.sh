#!/bin/zsh

source $SCRIPTS_PATH/notify-lib.sh

# Only notify while actually playing.
[[ "$(mpc status '%state%' 2>/dev/null)" == "playing" ]] || exit 0

artist=$(mpc current -f '%artist%' 2>/dev/null)
title=$(mpc current -f '%title%' 2>/dev/null)

# Skip notification when title is a raw URL or bare YouTube video ID (watch?v=...)
if [[ -n "$title" ]] && [[ "$title" != http://* ]] && [[ "$title" != https://* ]] && [[ "$title" != watch\?v=* ]]; then
  if [[ -n "$artist" ]]; then
    notify_send "$artist" "<span font='20px'>$title</span>" -r 101029 -a "system-notify"
  else
    notify_send "Now Playing" "<span font='20px'>$title</span>" -r 101029 -a "system-notify"
  fi
fi
