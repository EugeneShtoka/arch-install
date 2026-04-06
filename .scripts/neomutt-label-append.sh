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

rofi_dir="$HOME/.config/rofi/launchers/type-4"
selected=$(echo "$available" | $HOME/.scripts/rofi-run.sh -theme "${rofi_dir}/style-9-narrow.rasi" -dmenu -p "label" -matching fuzzy -i -multi-select -kb-accept-custom '' -kb-accept-entry 'ctrl+Return' -kb-accept-alt 'Return,space')
[[ -z $selected ]] && exit 0

echo "$selected" | while read -r tag; do
    notmuch tag "+$tag" "id:$msg_id"
done
~/.scripts/gmi-push.sh
