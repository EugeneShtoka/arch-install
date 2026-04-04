#!/bin/zsh
# One-time OAuth2 authorization for msmtp + goimapnotify
# Reuses gmailieer's client_id/secret, gets https://mail.google.com/ scope

CREDS=~/.local/share/mail/e.shtoka@gmail.com/.credentials.gmailieer.json
TOKENFILE=~/.cache/mutt_oauth2/e.shtoka@gmail.com.gpg

CLIENT_ID=$(python3 -c "import json; d=json.load(open('$CREDS')); print(d['client_id'])")
CLIENT_SECRET=$(python3 -c "import json; d=json.load(open('$CREDS')); print(d['client_secret'])")

python3 ~/.scripts/mutt_oauth2.py \
  --verbose \
  --authorize \
  --authflow localhostauthcode \
  --provider google \
  --email e.shtoka@gmail.com \
  --client-id "$CLIENT_ID" \
  --client-secret "$CLIENT_SECRET" \
  "$TOKENFILE"
