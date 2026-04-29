#!/bin/zsh

MATRIX_TOKEN=$(secret-tool lookup service "matrix" username "eugene")
MATRIX_BASE="https://matrix.cloud-surf.com"
SLACK_BOT="@slackbot:matrix.cloud-surf.com"
MATRIX_USER="@eugene:matrix.cloud-surf.com"
CDP_PORT=9222
SLACK_URL="https://slack.com/signin"

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

echo "==> Sending 'login' to slack bot (room $BOT_ROOM)..."
matrix_send "login"
sleep 1

echo "==> Killing Vivaldi..."
pkill -9 -f vivaldi 2>/dev/null
sleep 0.5
while pgrep -f vivaldi > /dev/null 2>&1; do sleep 0.3; done

echo "==> Launching Vivaldi (CDP port $CDP_PORT)..."
vivaldi \
  --remote-debugging-port=$CDP_PORT \
  "$SLACK_URL" \
  </dev/null &>/dev/null &

echo "==> Waiting for CDP..."
until curl -s "http://localhost:$CDP_PORT/json" > /dev/null 2>&1; do sleep 0.5; done
sleep 2

echo ""
echo "==> Log into your Slack workspace in the Vivaldi window."
echo "==> Waiting for xoxc token in localStorage (polling every 3s)..."

auth_token=""
d_cookie=""
while true; do
  # Re-fetch cdp_url each iteration — page URL changes after login redirect
  cdp_url=$(curl -s "http://localhost:$CDP_PORT/json" | jq -r 'map(select(.type=="page" and (.url|test("slack\\.com")))) | .[0].webSocketDebuggerUrl // empty')
  [[ -z "$cdp_url" ]] && { sleep 3; continue; }

  raw_cookies=$(echo '{"id":1,"method":"Network.getAllCookies","params":{}}' | websocat -1 "$cdp_url" 2>/dev/null)
  raw_token=$(echo '{"id":2,"method":"Runtime.evaluate","params":{"expression":"(function(){try{return Object.values(JSON.parse(localStorage.localConfig_v2).teams)[0].token}catch(e){return \"\"}})()"}}' | websocat -1 "$cdp_url" 2>/dev/null)

  auth_token=$(echo "$raw_token" | jq -r '.result.result.value // empty' 2>/dev/null)
  d_cookie=$(echo "$raw_cookies" | jq -r '.result.cookies[] | select(.name=="d" and (.domain|test("slack\\.com"))) | .value' 2>/dev/null | head -1)

  echo "  cdp_url=${cdp_url:0:60} auth=${auth_token:0:15} d=${d_cookie:0:15}"
  [[ "$auth_token" == xoxc-* && -n "$d_cookie" ]] && break
  sleep 3
done
echo "==> Got tokens!"

echo "==> auth_token: ${auth_token:0:20}..."
echo "==> cookie_token: ${d_cookie:0:20}..."

payload=$(python3 -c "import sys,json; print(json.dumps({'auth_token': sys.argv[1], 'cookie_token': sys.argv[2]}))" "$auth_token" "$d_cookie")
echo "==> Sending credentials to slack bot..."
matrix_send "$payload"

echo ""
echo "==> Done! Check the slack bot room."
