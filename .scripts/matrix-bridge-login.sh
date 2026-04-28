#!/bin/zsh

SERVER="https://matrix.cloud-surf.com"
DOMAIN="matrix.cloud-surf.com"
APPSERVICE_TOKEN="656a56520c3b6175e98ff0ad94f15875609f8a9a4b22600bdc7e156ca04784a0"

# QR-based logins (sequential — scan one at a time)
QR_BOTS=(whatsapp-bg-bot whatsapp-il-bot gmessagesbot)
# Other logins (just trigger, handle manually in Element)
OTHER_BOTS=(metabot slackbot telegrambot linkedinbot signalbot)

# Get fresh token via doublepuppet appservice
TOKEN=$(curl -s -X POST "${SERVER}/_matrix/client/v3/login" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${APPSERVICE_TOKEN}" \
  -d '{"type":"m.login.application_service","identifier":{"type":"m.id.user","user":"eugene"},"user":"eugene"}' \
  | python3 -c "import sys,json; print(json.load(sys.stdin)['access_token'])")

if [[ -z "$TOKEN" ]]; then
  echo "Failed to get access token" >&2
  exit 1
fi

txn() { echo "txn$(date +%s%N)$RANDOM"; }

send_msg() {
  local room=$1 msg=$2
  curl -s -X PUT "${SERVER}/_matrix/client/v3/rooms/${room}/send/m.room.message/$(txn)" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d "{\"msgtype\":\"m.text\",\"body\":\"${msg}\"}" | python3 -c "import sys,json; print(json.load(sys.stdin).get('event_id',''))"
}

# Return existing DM room with bot, or empty string
get_existing_dm() {
  local bot=$1
  curl -s "${SERVER}/_matrix/client/v3/user/@eugene:${DOMAIN}/account_data/m.direct" \
    -H "Authorization: Bearer $TOKEN" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    rooms = data.get('@${bot}:${DOMAIN}', [])
    if rooms: print(rooms[-1])
except: pass
" 2>/dev/null
}

get_or_create_dm() {
  local bot=$1
  local room=$(get_existing_dm "$bot")
  if [[ -n "$room" ]]; then
    echo "  (reusing existing room $room)" >&2
    echo "$room"
    return
  fi
  curl -s -X POST "${SERVER}/_matrix/client/v3/createRoom" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d "{\"invite\":[\"@${bot}:${DOMAIN}\"],\"is_direct\":true,\"preset\":\"private_chat\",\"initial_state\":[]}" \
    | python3 -c "import sys,json; print(json.load(sys.stdin).get('room_id',''))"
}

show_qr() {
  local mxc=$1
  local media_path="${mxc#mxc://}"
  local tmp=$(mktemp /tmp/qr-XXXXX.png)
  curl -s -L "${SERVER}/_matrix/media/v3/download/${media_path}" \
    -H "Authorization: Bearer $TOKEN" -o "$tmp"
  wezterm imgcat "$tmp"
  rm -f "$tmp"
}

wait_for_qr() {
  local room=$1 bot=$2 since_ts=$3
  local last_mxc=""
  # Get pagination token from current end of timeline
  local page_token
  page_token=$(curl -s "${SERVER}/_matrix/client/v3/rooms/${room}/messages?dir=b&limit=1" \
    -H "Authorization: Bearer $TOKEN" | python3 -c "import sys,json; print(json.load(sys.stdin).get('end',''))" 2>/dev/null)

  echo "  Waiting for QR code..."

  for i in {1..60}; do
    sleep 2
    local resp result new_token
    # Poll forward from our saved position
    resp=$(curl -s "${SERVER}/_matrix/client/v3/rooms/${room}/messages?dir=f&from=${page_token}&limit=20" \
      -H "Authorization: Bearer $TOKEN")
    new_token=$(echo "$resp" | python3 -c "import sys,json; print(json.load(sys.stdin).get('end',''))" 2>/dev/null)
    [[ -n "$new_token" ]] && page_token="$new_token"

    result=$(echo "$resp" | python3 -c "
import sys, json
data = json.load(sys.stdin)
for ev in data.get('chunk', []):
    sender = ev.get('sender','')
    if 'bot' not in sender:
        continue
    ct = ev.get('content', {})
    # For replacement events, prefer m.new_content
    if 'm.new_content' in ct:
        ct = ct['m.new_content']
    body = ct.get('body','')
    if ct.get('msgtype') == 'm.text' and any(w in body.lower() for w in ['logged in', 'successfully', 'connected']):
        print('SUCCESS:' + body)
        break
    if ct.get('msgtype') == 'm.image':
        print('IMAGE:' + ct.get('url',''))
        break
    if ct.get('msgtype') == 'm.text' and len(body) > 20 and 'hello' not in body.lower() and 'help' not in body.lower() and 'timed out' not in body.lower():
        print('TEXT:' + body)
        break
" 2>/dev/null)

    [[ -z "$result" ]] && continue

    if [[ "$result" == SUCCESS:* ]]; then
      echo "  ✓ ${result#SUCCESS:}"
      return 0
    elif [[ "$result" == IMAGE:* ]]; then
      local mxc="${result#IMAGE:}"
      if [[ "$mxc" != "$last_mxc" ]]; then
        last_mxc="$mxc"
        echo "  Scan this QR code (refreshes every ~20s):"
        show_qr "$mxc"
      fi
    elif [[ "$result" == TEXT:* ]]; then
      echo "  ${result#TEXT:}"
    fi
  done

  echo "  Timed out for $bot"
  return 1
}

echo "=== Matrix Bridge Login ==="
echo ""

for bot in "${QR_BOTS[@]}"; do
  echo "--- $bot ---"
  room=$(get_or_create_dm "$bot")
  if [[ -z "$room" ]]; then
    echo "  Failed to get room, skipping"
    continue
  fi
  echo "  Room: $room"
  sleep 3
  local since_ts=$(( $(date +%s%3N) ))
  send_msg "$room" "login qr" >/dev/null
  wait_for_qr "$room" "$bot" "$since_ts"
  echo "  Press Enter to continue to next bridge..."
  read
  echo ""
done

echo "--- Other bridges (handle auth in Element) ---"
for bot in "${OTHER_BOTS[@]}"; do
  room=$(get_or_create_dm "$bot")
  if [[ -z "$room" ]]; then
    echo "  $bot: failed to get room"
    continue
  fi
  sleep 2
  send_msg "$room" "login" >/dev/null
  echo "  $bot → $room"
done

echo ""
echo "Done. Open Element to complete auth for: ${OTHER_BOTS[*]}"
