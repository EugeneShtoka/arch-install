#!/bin/zsh
msg_id=$(grep -m1 -i "^Message-ID:" | awk '{print $2}' | tr -d '<>')
[[ -z $msg_id ]] && exit 0

current_tags=$(notmuch search --output=tags "id:$msg_id" | sort)
all_tags=$(notmuch search --output=tags '*' | sort)
excluded="spam\ntrash\ninbox"

available=$(comm -23 \
    <(echo "$all_tags") \
    <(printf "$excluded\n$current_tags" | sort))

[[ -z $available ]] && exit 0

selected=$(echo "$available" | rofi -dmenu -p "Add label:")
[[ -z $selected ]] && exit 0

notmuch tag "+$selected" "id:$msg_id"
~/.scripts/gmi-push.sh
