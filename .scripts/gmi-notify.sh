#!/bin/zsh
latest=$(notmuch search --output=messages --limit=1 tag:inbox and tag:unread)
[[ -z $latest ]] && exit 0
headers=$(notmuch show --format=text "$latest")
from=${${(f)${headers[(r)From:*]}}[1]#From: }
subject=${${(f)${headers[(r)Subject:*]}}[1]#Subject: }
notify-send -i mail-unread "$from" "$subject"
