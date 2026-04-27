#!/bin/zsh

MATRIX_TOKEN=$(secret-tool lookup service "matrix" username "eugene")
MATRIX_BASE="https://matrix.cloud-surf.com"
GMESSAGES_BOT="@gmessagesbot:matrix.cloud-surf.com"
MATRIX_USER="@eugene:matrix.cloud-surf.com"
SOCKS_PORT=1080
CDP_PORT=9222
GOOGLE_URL="https://accounts.google.com/AccountChooser?continue=https://messages.google.com/web/config"
COOKIE_KEYS=(SID HSID SSID OSID APISID SAPISID __Secure-1PSIDTS)

# Resolve gmessages bot DM room via m.direct account data
BOT_ROOM=$(curl -s \
  "$MATRIX_BASE/_matrix/client/v3/user/$MATRIX_USER/account_data/m.direct" \
  -H "Authorization: Bearer $MATRIX_TOKEN" \
  | jq -r --arg bot "$GMESSAGES_BOT" '.[$bot][0] // empty')

if [[ -z "$BOT_ROOM" ]]; then
  echo "ERROR: Could not find DM room with $GMESSAGES_BOT"
  exit 1
fi

BOT_ROOM_ENC=$(python3 -c "import sys,urllib.parse; print(urllib.parse.quote(sys.argv[1], safe=''))" "$BOT_ROOM")

matrix_send() {
  local body="$1"
  local txn=$(date +%s%N)
  curl -s -X PUT \
    "$MATRIX_BASE/_matrix/client/v3/rooms/$BOT_ROOM_ENC/send/m.room.message/$txn" \
    -H "Authorization: Bearer $MATRIX_TOKEN" \
    -H "Content-Type: application/json" \
    -d "{\"msgtype\":\"m.text\",\"body\":$(python3 -c "import sys,json; print(json.dumps(sys.argv[1]))" "$body")}" \
    > /dev/null
}

echo "==> Enabling TCP forwarding on VPS..."
ssh hetzner "sudo sed -i 's/AllowTcpForwarding no/AllowTcpForwarding yes/' /etc/ssh/sshd_config.d/hardening.conf && sudo systemctl reload ssh" || true
stty sane 2>/dev/null

echo "==> Starting SSH SOCKS tunnel..."
ssh -D $SOCKS_PORT -N hetzner &
SSH_PID=$!
sleep 2

cleanup() {
  echo "==> Cleaning up tunnel..."
  kill $SSH_PID 2>/dev/null
  ssh hetzner "sudo sed -i 's/AllowTcpForwarding yes/AllowTcpForwarding no/' /etc/ssh/sshd_config.d/hardening.conf && sudo systemctl reload ssh" &>/dev/null &
}
trap cleanup EXIT

echo "==> Sending 'login google' to gmessages bot (room $BOT_ROOM)..."
matrix_send "login google"
sleep 1

echo "==> Killing Vivaldi..."
pkill -9 -f vivaldi 2>/dev/null
sleep 0.5
while pgrep -f vivaldi > /dev/null 2>&1; do sleep 0.3; done

echo "==> Launching Vivaldi (incognito, via SOCKS tunnel, CDP port $CDP_PORT)..."
vivaldi \
  --proxy-server="socks5://127.0.0.1:$SOCKS_PORT" \
  --remote-debugging-port=$CDP_PORT \
  --incognito \
  "$GOOGLE_URL" \
  </dev/null &>/dev/null &

echo "==> Waiting for CDP..."
until curl -s "http://localhost:$CDP_PORT/json" > /dev/null 2>&1; do sleep 0.5; done
sleep 2

cdp_url=$(curl -s "http://localhost:$CDP_PORT/json" | jq -r 'map(select(.type=="page")) | .[0].webSocketDebuggerUrl')
echo "==> CDP: $cdp_url"

echo ""
echo "==> Log into your Google account in the Vivaldi window."
echo "==> Press Enter here when you are on the messages.google.com/web/config page..."
read

echo "==> Fetching cookies via CDP..."
raw=$(echo '{"id":1,"method":"Network.getAllCookies","params":{}}' | websocat -1 "$cdp_url" 2>/dev/null)

if [[ -z "$raw" ]]; then
  echo "ERROR: No response from CDP"
  exit 1
fi

json=$(echo "$raw" | jq '[
  .result.cookies[]
  | select(.name as $n | ["SID","HSID","SSID","OSID","APISID","SAPISID","__Secure-1PSIDTS"] | index($n) != null)
  | select(.domain | test("google\\.com"))
] | unique_by(.name) | map({(.name): .value}) | add')

if [[ -z "$json" || "$json" == "null" || "$json" == "{}" ]]; then
  echo "ERROR: No cookies extracted"
  exit 1
fi

echo "==> Cookies: $json"
echo "==> Sending to Matrix bot..."
matrix_send "$json"

echo ""
echo "==> Done! Check the gmessages bot room — tap the emoji it sends on your phone."
