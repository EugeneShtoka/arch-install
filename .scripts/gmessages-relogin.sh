#!/bin/zsh

MATRIX_TOKEN=$(secret-tool lookup service "matrix" username "eugene")
MATRIX_BASE="https://matrix.cloud-surf.com"
BOT_ROOM="!PcleGWfeA4dFQYbtZT:matrix.cloud-surf.com"
BOT_ROOM_ENC="%21PcleGWfeA4dFQYbtZT%3Amatrix.cloud-surf.com"
SOCKS_PORT=1080
CDP_PORT=9222
TARGET_URL="messages.google.com/web/config"
GOOGLE_URL="https://accounts.google.com/AccountChooser?continue=https://messages.google.com/web/config"

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

echo "==> Sending logout to gmessages bot..."
matrix_send "logout"
sleep 1

echo "==> Killing Vivaldi..."
pkill -f vivaldi 2>/dev/null
sleep 1

echo "==> Starting SSH SOCKS tunnel..."
if ! ss -tlnp 2>/dev/null | grep -q ":$SOCKS_PORT "; then
  ssh -D $SOCKS_PORT -N hetzner &
  sleep 2
fi

echo "==> Launching Vivaldi..."
vivaldi \
  --proxy-server="socks5://127.0.0.1:$SOCKS_PORT" \
  --remote-debugging-port=$CDP_PORT \
  --incognito \
  "$GOOGLE_URL" \
  &>/dev/null &

echo "==> Waiting for CDP..."
until curl -s http://localhost:$CDP_PORT/json > /dev/null 2>&1; do sleep 0.5; done
sleep 1

cdp_url=$(curl -s http://localhost:$CDP_PORT/json | jq -r 'map(select(.type=="page")) | .[0].webSocketDebuggerUrl')
echo "==> CDP: $cdp_url"

# Set up websocat with a named pipe for input
cdp_pipe=$(mktemp -u /tmp/cdp-pipe-XXXXX)
mkfifo "$cdp_pipe"
exec 4>"$cdp_pipe"

> /tmp/cdp-events.log
websocat "$cdp_url" < "$cdp_pipe" >> /tmp/cdp-events.log &
WS_PID=$!

echo '{"id":1,"method":"Network.enable","params":{}}' >&4

echo "==> Waiting for Google Messages config request — log in now..."

# Wait for the matching network event
result=$(tail -f /tmp/cdp-events.log 2>/dev/null | grep -m1 "$TARGET_URL")

exec 4>&-
kill $WS_PID 2>/dev/null
rm -f "$cdp_pipe"

echo "==> Got config request, extracting curl command..."

curl_cmd=$(echo "$result" | jq -r '
  .params.request |
  "curl " + (.url | @sh) +
  (.headers | to_entries | map(" \\\n  -H " + ((.key + ": " + .value) | @sh)) | join(""))
')

echo "==> Sending to Matrix bot..."
matrix_send "$curl_cmd"

echo "==> Done! Check the gmessages bot room."
