#!/bin/zsh
latest=$(notmuch search --output=messages --limit=1 tag:inbox and tag:unread)
[[ -z $latest ]] && exit 0
from=$(notmuch show --format=json "$latest" | python3 -c "import sys,json; print(json.load(sys.stdin)[0][0][0]['headers']['From'])")
subject=$(notmuch show --format=json "$latest" | python3 -c "import sys,json; print(json.load(sys.stdin)[0][0][0]['headers']['Subject'])")
notify-send -i mail-unread "$from" "$subject"
