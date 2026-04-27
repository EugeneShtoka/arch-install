#!/bin/zsh

# Meta (Facebook/Messenger/Instagram) bridge re-login
# Usage: meta-relogin.sh [facebook|messenger|instagram]
# If bridge is pre-configured with a mode, omit arg and script will prompt.

MATRIX_TOKEN=$(secret-tool lookup service "matrix" username "eugene")
MATRIX_BASE="https://matrix.cloud-surf.com"
MATRIX_USER="@eugene:matrix.cloud-surf.com"
META_BOT="@metabot:matrix.cloud-surf.com"
CDP_PORT=9222

# Resolve meta bot DM room via m.direct account data
BOT_ROOM=$(curl -s \
  "$MATRIX_BASE/_matrix/client/v3/user/$MATRIX_USER/account_data/m.direct" \
  -H "Authorization: Bearer $MATRIX_TOKEN" \
  | jq -r --arg bot "$META_BOT" '.[$bot][0] // empty')

if [[ -z "$BOT_ROOM" ]]; then
  echo "ERROR: Could not find DM room with $META_BOT"
  exit 1
fi

BOT_ROOM_ENC=$(python3 -c "import sys,urllib.parse; print(urllib.parse.quote(sys.argv[1], safe=''))" "$BOT_ROOM")

MODE="messenger"
OPEN_URL="https://www.messenger.com"
COOKIE_DOMAIN=".facebook.com"
COOKIE_KEYS=(datr c_user sb xs)

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
ssh -n hetzner "sudo sed -i 's/AllowTcpForwarding no/AllowTcpForwarding yes/' /etc/ssh/sshd_config.d/hardening.conf && sudo systemctl reload ssh" || true
stty sane 2>/dev/null

echo "==> Starting SSH tunnel to VPS tinyproxy (port 8888)..."
if ss -tlnp 2>/dev/null | grep -q ":8888 "; then
  echo "    (tunnel already running, reusing)"
  SSH_PID=""
else
  ssh -n -L 8888:localhost:8888 -N hetzner &
  SSH_PID=$!
  sleep 2
fi

cleanup() {
  echo "==> Cleaning up tunnel..."
  kill $SSH_PID 2>/dev/null
  ssh hetzner "sudo sed -i 's/AllowTcpForwarding yes/AllowTcpForwarding no/' /etc/ssh/sshd_config.d/hardening.conf && sudo systemctl reload ssh" &>/dev/null &
}
trap cleanup EXIT

echo "==> Sending 'login $MODE' to meta bot (room $BOT_ROOM)..."
matrix_send "login $MODE"
sleep 1

echo "==> Killing Vivaldi..."
pkill -9 -f vivaldi 2>/dev/null
sleep 0.5
while pgrep -f vivaldi > /dev/null 2>&1; do sleep 0.3; done

echo "==> Launching Vivaldi (incognito, via VPS proxy, CDP port $CDP_PORT)..."
vivaldi \
  --remote-debugging-port=$CDP_PORT \
  --proxy-server="http://localhost:8888" \
  --incognito \
  "$OPEN_URL" \
  </dev/null &>/dev/null &

echo "==> Waiting for CDP..."
until curl -s "http://localhost:$CDP_PORT/json" > /dev/null 2>&1; do sleep 0.5; done
sleep 2

cdp_url=$(curl -s "http://localhost:$CDP_PORT/json" | jq -r 'map(select(.type=="page")) | .[0].webSocketDebuggerUrl')
echo "==> CDP: $cdp_url"

echo ""
echo "==> Log in at $OPEN_URL in the Vivaldi window."
echo "==> Waiting for login cookies (polling every 3s)..."

raw=""
while true; do
  raw=$(echo '{"id":1,"method":"Network.getAllCookies","params":{}}' | websocat -1 "$cdp_url" 2>/dev/null)
  c_user=$(echo "$raw" | jq -r '.result.cookies[] | select(.name=="c_user") | .value' 2>/dev/null | head -1)
  [[ -n "$c_user" ]] && break
  sleep 3
done
echo "==> Logged in!"

json=$(echo "$raw" | jq '[
  .result.cookies[]
  | select(.name as $n | ["datr","c_user","sb","xs"] | index($n) != null)
  | select(.domain | test("facebook\\.com|messenger\\.com"))
] | unique_by(.name) | map({(.name): .value}) | add | {datr,c_user,sb,xs}')

if [[ -z "$json" || "$json" == "null" || "$json" == "{}" ]]; then
  echo "ERROR: No cookies extracted"
  exit 1
fi

echo "==> Cookies: $json"
echo "==> Sending to Matrix bot..."
matrix_send "$json"

echo "==> Done! Check the meta bot room."
