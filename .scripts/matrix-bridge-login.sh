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

create_dm() {
  local bot=$1
  curl -s -X POST "${SERVER}/_matrix/client/v3/createRoom" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d "{\"invite\":[\"@${bot}:${DOMAIN}\"],\"is_direct\":true,\"preset\":\"private_chat\",\"initial_state\":[]}" \
    | python3 -c "import sys,json; print(json.load(sys.stdin).get('room_id',''))"
}

wait_for_qr() {
  local room=$1 bot=$2
  echo "  Waiting for QR code..."
  for i in {1..60}; do
    sleep 1
    local result
    result=$(curl -s "${SERVER}/_matrix/client/v3/rooms/${room}/messages?dir=b&limit=10" \
      -H "Authorization: Bearer $TOKEN" | python3 -c "
import sys, json
data = json.load(sys.stdin)
for ev in data.get('chunk', []):
    sender = ev.get('sender','')
    ct = ev.get('content', {})
    # QR as image
    if ct.get('msgtype') == 'm.image' and 'bot' in sender:
        print('IMAGE:' + ct.get('url',''))
        break
    # QR as text/code block
    if ct.get('msgtype') == 'm.text' and 'bot' in sender:
        body = ct.get('body','')
        if len(body) > 20 and 'Hello' not in body and 'help' not in body.lower():
            print('TEXT:' + body)
            break
" 2>/dev/null)
    [[ -n "$result" ]] && break
  done

  if [[ -z "$result" ]]; then
    echo "  Timed out waiting for QR from $bot"
    return 1
  fi

  if [[ "$result" == IMAGE:* ]]; then
    local mxc="${result#IMAGE:}"
    local media_path="${mxc#mxc://}"
    local tmp=$(mktemp /tmp/qr-XXXXX.png)
    curl -s -L "${SERVER}/_matrix/media/v3/download/${media_path}" \
      -H "Authorization: Bearer $TOKEN" -o "$tmp"
    wezterm imgcat "$tmp"
    rm "$tmp"
  else
    echo "${result#TEXT:}"
  fi
}

echo "=== Matrix Bridge Login ==="
echo ""

# QR bridges — sequential
for bot in "${QR_BOTS[@]}"; do
  echo "--- $bot ---"
  room=$(create_dm "$bot")
  if [[ -z "$room" ]]; then
    echo "  Failed to create room, skipping"
    continue
  fi
  echo "  Room: $room"
  sleep 3  # wait for bot to join
  send_msg "$room" "login" >/dev/null
  wait_for_qr "$room" "$bot"
  echo ""
  echo "  Scan the QR, then press Enter to continue..."
  read
  echo ""
done

# Other bridges — create rooms and trigger login
echo "--- Other bridges (handle auth in Element) ---"
for bot in "${OTHER_BOTS[@]}"; do
  room=$(create_dm "$bot")
  sleep 2
  send_msg "$room" "login" >/dev/null
  echo "  $bot → $room"
done

echo ""
echo "Done. Open Element to complete auth for: ${OTHER_BOTS[*]}"
