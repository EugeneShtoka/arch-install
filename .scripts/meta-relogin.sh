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

MODE="${1:-}"
if [[ -z "$MODE" ]]; then
  echo "Mode? [facebook/messenger/instagram]: "
  read MODE
fi

case "$MODE" in
  facebook)
    OPEN_URL="https://www.facebook.com"
    GRAPHQL_PATTERN="facebook.com/api/graphql"
    COOKIE_KEYS=(datr c_user sb xs)
    ;;
  messenger)
    OPEN_URL="https://www.messenger.com"
    GRAPHQL_PATTERN="messenger.com/api/graphql"
    COOKIE_KEYS=(datr c_user sb xs)
    ;;
  instagram)
    OPEN_URL="https://www.instagram.com"
    GRAPHQL_PATTERN="instagram.com/graphql"
    COOKIE_KEYS=(sessionid csrftoken mid ig_did ds_user_id)
    ;;
  *)
    echo "ERROR: Unknown mode '$MODE'. Use: facebook, messenger, instagram"
    exit 1
    ;;
esac

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

echo "==> Sending 'login $MODE' to meta bot (room $BOT_ROOM)..."
matrix_send "login $MODE"
sleep 1

echo "==> Killing Vivaldi..."
pkill -f vivaldi 2>/dev/null
sleep 1

echo "==> Launching Vivaldi (incognito, CDP port $CDP_PORT)..."
vivaldi \
  --remote-debugging-port=$CDP_PORT \
  --incognito \
  "$OPEN_URL" \
  &>/dev/null &

echo "==> Waiting for CDP..."
until curl -s "http://localhost:$CDP_PORT/json" > /dev/null 2>&1; do sleep 0.5; done
sleep 1

cdp_url=$(curl -s "http://localhost:$CDP_PORT/json" | jq -r 'map(select(.type=="page")) | .[0].webSocketDebuggerUrl')
echo "==> CDP: $cdp_url"

cdp_pipe=$(mktemp -u /tmp/cdp-pipe-XXXXX)
mkfifo "$cdp_pipe"
exec 4>"$cdp_pipe"

> /tmp/cdp-events.log
websocat "$cdp_url" < "$cdp_pipe" >> /tmp/cdp-events.log &
WS_PID=$!

echo '{"id":1,"method":"Network.enable","params":{}}' >&4

echo "==> Log in at $OPEN_URL now — waiting for graphql request..."

result=$(tail -f /tmp/cdp-events.log 2>/dev/null | grep -m1 "$GRAPHQL_PATTERN")

exec 4>&-
kill $WS_PID 2>/dev/null
rm -f "$cdp_pipe"

echo "==> Got graphql request, extracting cookies..."

cookie_header=$(echo "$result" | jq -r '.params.request.headers.Cookie // .params.request.headers.cookie // ""')

if [[ -z "$cookie_header" ]]; then
  echo "ERROR: No Cookie header found in captured request"
  exit 1
fi

parse_cookie() {
  local name="$1"
  echo "$cookie_header" \
    | tr ';' '\n' \
    | grep -m1 "^[[:space:]]*${name}=" \
    | sed "s/^[[:space:]]*${name}=//; s/[[:space:]]*$//" \
    | python3 -c "import sys,urllib.parse; print(urllib.parse.unquote(sys.stdin.read().strip()))"
}

json="{"
first=1
for key in "${COOKIE_KEYS[@]}"; do
  val=$(parse_cookie "$key")
  if [[ -n "$val" ]]; then
    [[ $first -eq 0 ]] && json+=","
    json+="\"$key\":$(python3 -c "import sys,json; print(json.dumps(sys.argv[1]))" "$val")"
    first=0
  fi
done
json+="}"

echo "==> Cookies: $json"
echo "==> Sending to Matrix bot..."
matrix_send "$json"

echo "==> Done! Check the meta bot room."
