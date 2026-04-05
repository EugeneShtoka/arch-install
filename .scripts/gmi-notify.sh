#!/bin/zsh
latest=$(notmuch search --output=messages --limit=1 tag:inbox)
[[ -z $latest ]] && exit 0
msg=$(notmuch show --format=text "$latest")
from=$(echo "$msg" | grep "^From:" | head -1 | cut -d' ' -f2-)
subject=$(echo "$msg" | grep "^Subject:" | head -1 | cut -d' ' -f2-)
notify-send -i mail-unread "$from" "$subject"
