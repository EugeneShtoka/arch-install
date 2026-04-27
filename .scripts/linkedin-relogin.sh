#!/bin/zsh

MATRIX_TOKEN=$(secret-tool lookup service "matrix" username "eugene")
MATRIX_BASE="https://matrix.cloud-surf.com"
LINKEDIN_BOT="@linkedinbot:matrix.cloud-surf.com"
MATRIX_USER="@eugene:matrix.cloud-surf.com"
CDP_PORT=9222
PROXY_PORT=8888
LINKEDIN_URL="https://www.linkedin.com"
BRIDGE_UA="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36"

# Resolve linkedin bot DM room via m.direct account data
BOT_ROOM=$(curl -s \
  "$MATRIX_BASE/_matrix/client/v3/user/$MATRIX_USER/account_data/m.direct" \
  -H "Authorization: Bearer $MATRIX_TOKEN" \
  | jq -r --arg bot "$LINKEDIN_BOT" '.[$bot][0] // empty')

if [[ -z "$BOT_ROOM" ]]; then
  echo "ERROR: Could not find DM room with $LINKEDIN_BOT"
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
ssh hetzner "sudo sed -i 's/AllowTcpForwarding no/AllowTcpForwarding yes/' /etc/ssh/sshd_config.d/hardening.conf && sudo systemctl restart ssh"

echo "==> Starting SSH tunnel to VPS tinyproxy (port $PROXY_PORT)..."
ssh -L "${PROXY_PORT}:localhost:${PROXY_PORT}" -N hetzner &
SSH_PID=$!
sleep 2

cleanup() {
  echo "==> Cleaning up tunnel..."
  kill $SSH_PID 2>/dev/null
  ssh hetzner "sudo sed -i 's/AllowTcpForwarding yes/AllowTcpForwarding no/' /etc/ssh/sshd_config.d/hardening.conf && sudo systemctl restart ssh" &>/dev/null &
}
trap cleanup EXIT

echo "==> Sending 'login' to linkedin bot (room $BOT_ROOM)..."
matrix_send "login"
sleep 1

echo "==> Killing Vivaldi..."
pkill -9 -f vivaldi 2>/dev/null
sleep 0.5
while pgrep -f vivaldi > /dev/null 2>&1; do sleep 0.3; done

echo "==> Launching Vivaldi (incognito, via VPS proxy, spoofed UA, CDP port $CDP_PORT)..."
vivaldi \
  --proxy-server="http://localhost:$PROXY_PORT" \
  --user-agent="$BRIDGE_UA" \
  --remote-debugging-port=$CDP_PORT \
  --incognito \
  "$LINKEDIN_URL" \
  &>/dev/null &

echo "==> Waiting for CDP..."
until curl -s "http://localhost:$CDP_PORT/json" > /dev/null 2>&1; do sleep 0.5; done
sleep 2

cdp_url=$(curl -s "http://localhost:$CDP_PORT/json" | jq -r 'map(select(.type=="page")) | .[0].webSocketDebuggerUrl')
echo "==> CDP: $cdp_url"

echo ""
echo "==> Verify IP at http://ifconfig.me — must show VPS IP (65.21.3.202)."
echo "==> If already logged in, log out first (session was under wrong UA)."
echo "==> Log into linkedin.com, then navigate to the feed."
echo "==> Press Enter here when you are on the LinkedIn feed page..."
read

echo ""
echo "==> Verify IP at http://ifconfig.me — must show VPS IP (65.21.3.202)."
echo "==> If already logged in, log out first (session was under wrong UA)."
echo "==> Log into linkedin.com, then navigate to the feed."
echo "==> Press Enter here when you are on the LinkedIn feed page..."
read

echo "==> Capturing LinkedIn API request headers (reloading page)..."
api_event=$(
  {
    echo '{"id":1,"method":"Network.enable","params":{}}'
    echo '{"id":2,"method":"Page.reload","params":{}}'
    sleep 3600
  } \
  | websocat -B 5000000 "$cdp_url" \
  | grep -m1 "voyager/api"
)

if [[ -z "$api_event" ]]; then
  echo "ERROR: Could not capture LinkedIn API request"
  exit 1
fi

echo "==> Fetching cookies via CDP..."
raw=$(echo '{"id":1,"method":"Network.getAllCookies","params":{}}' | websocat -1 "$cdp_url" 2>/dev/null)

li_at=$(echo "$raw" | jq -r '
  .result.cookies[]
  | select(.name == "li_at" and (.domain | test("linkedin\\.com")))
  | .value' | head -1)

jsessionid=$(echo "$raw" | jq -r '
  .result.cookies[]
  | select(.name == "JSESSIONID" and (.domain | test("linkedin\\.com")))
  | .value' | head -1)

if [[ -z "$li_at" ]]; then
  echo "ERROR: li_at cookie not found — are you logged in?"
  exit 1
fi

cookie_header="li_at=${li_at}"
[[ -n "$jsessionid" ]] && cookie_header+="; JSESSIONID=${jsessionid}"

x_li_track=$(echo "$api_event" | jq -r '
  .params.request.headers
  | to_entries[]
  | select(.key | ascii_downcase == "x-li-track")
  | .value' | head -1)

x_li_page_instance=$(echo "$api_event" | jq -r '
  .params.request.headers
  | to_entries[]
  | select(.key | ascii_downcase == "x-li-page-instance")
  | .value' | head -1)

json=$(python3 -c "
import sys, json
d = {'fi.mau.linkedin.login.cookie_header': sys.argv[1]}
if sys.argv[2]: d['fi.mau.linkedin.login.x_li_track'] = sys.argv[2]
if sys.argv[3]: d['fi.mau.linkedin.login.x_li_page_instance'] = sys.argv[3]
print(json.dumps(d))
" "$cookie_header" "$x_li_track" "$x_li_page_instance")

echo "==> Sending to Matrix bot (keep browser open)..."
matrix_send "$json"

echo ""
echo "==> Done! Check the linkedin bot room."
