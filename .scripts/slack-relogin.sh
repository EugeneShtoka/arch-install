#!/bin/zsh

MATRIX_TOKEN=$(secret-tool lookup service "matrix" username "eugene")
MATRIX_BASE="https://matrix.cloud-surf.com"
SLACK_BOT="@slackbot:matrix.cloud-surf.com"
MATRIX_USER="@eugene:matrix.cloud-surf.com"
CDP_PORT=9222
PROXY_PORT=8888
SLACK_URL="https://slack.com"

# Resolve slackbot DM room via m.direct account data
BOT_ROOM=$(curl -s \
  "$MATRIX_BASE/_matrix/client/v3/user/$MATRIX_USER/account_data/m.direct" \
  -H "Authorization: Bearer $MATRIX_TOKEN" \
  | jq -r --arg bot "$SLACK_BOT" '.[$bot][0] // empty')

if [[ -z "$BOT_ROOM" ]]; then
  echo "ERROR: Could not find DM room with $SLACK_BOT"
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
ssh -n hetzner "sudo sed -i 's/AllowTcpForwarding no/AllowTcpForwarding yes/' /etc/ssh/sshd_config.d/hardening.conf && sudo systemctl reload ssh" || true
stty sane 2>/dev/null

echo "==> Starting SSH tunnel to VPS tinyproxy (port $PROXY_PORT)..."
if ss -tlnp 2>/dev/null | grep -q ":${PROXY_PORT} "; then
  echo "    (tunnel already running, reusing)"
  SSH_PID=""
else
  ssh -n -L "${PROXY_PORT}:localhost:${PROXY_PORT}" -N hetzner &
  SSH_PID=$!
  sleep 2
fi

cleanup() {
  echo "==> Cleaning up tunnel..."
  [[ -n "$SSH_PID" ]] && kill $SSH_PID 2>/dev/null
  ssh hetzner "sudo sed -i 's/AllowTcpForwarding yes/AllowTcpForwarding no/' /etc/ssh/sshd_config.d/hardening.conf && sudo systemctl reload ssh" &>/dev/null &
}
trap cleanup EXIT

echo "==> Sending 'login' to slack bot (room $BOT_ROOM)..."
matrix_send "login"
sleep 1

echo "==> Killing Vivaldi..."
pkill -9 -f vivaldi 2>/dev/null
sleep 0.5
while pgrep -f vivaldi > /dev/null 2>&1; do sleep 0.3; done

echo "==> Launching Vivaldi (incognito, via VPS proxy, CDP port $CDP_PORT)..."
vivaldi \
  --proxy-server="http://localhost:$PROXY_PORT" \
  --remote-debugging-port=$CDP_PORT \
  --incognito \
  "$SLACK_URL" \
  </dev/null &>/dev/null &

echo "==> Waiting for CDP..."
until curl -s "http://localhost:$CDP_PORT/json" > /dev/null 2>&1; do sleep 0.5; done
sleep 2

cdp_url=$(curl -s "http://localhost:$CDP_PORT/json" | jq -r 'map(select(.type=="page")) | .[0].webSocketDebuggerUrl')
echo "==> CDP: $cdp_url"

echo ""
echo "==> Verify IP at http://ifconfig.me — must show VPS IP (65.21.3.202)."
echo "==> Log into your Slack workspace in the Vivaldi window."
echo "==> Waiting for Slack 'd' cookie (polling every 3s)..."

raw=""
while true; do
  raw=$(echo '{"id":1,"method":"Network.getAllCookies","params":{}}' | websocat -1 "$cdp_url" 2>/dev/null)
  d_cookie=$(echo "$raw" | jq -r '.result.cookies[] | select(.name=="d" and (.domain|test("slack\\.com"))) | .value' 2>/dev/null | head -1)
  [[ -n "$d_cookie" ]] && break
  sleep 3
done
echo "==> Logged in!"

d_s_cookie=$(echo "$raw" | jq -r '.result.cookies[] | select(.name=="d-s" and (.domain|test("slack\\.com"))) | .value' 2>/dev/null | head -1)

echo "==> d cookie: ${d_cookie:0:20}..."
echo "==> Sending login-token to slack bot..."
matrix_send "login-token ${d_cookie}"

echo ""
echo "==> Done! Check the slack bot room."
