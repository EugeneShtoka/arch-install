#!/bin/zsh

source ~/.scripts/matrix-lib.sh
matrix_connect "slackbot" || exit 1

CDP_PORT=9222

cdp_eval() {
  local cdp_url="$1" cmd="$2"
  echo "$cmd" | timeout 5 websocat "$cdp_url" 2>/dev/null | tr -d '\000-\037'
}

echo "==> Sending 'login' to slack bot (room $BOT_ROOM)..."
matrix_send "login"
sleep 1

# Launch Vivaldi with CDP if not already running, or if no CDP port is open
if ! curl -s "http://localhost:$CDP_PORT/json" > /dev/null 2>&1; then
  echo "==> Launching Vivaldi (CDP port $CDP_PORT)..."
  vivaldi --remote-debugging-port=$CDP_PORT 'https://app.slack.com' </dev/null &>/dev/null &
  echo "==> Waiting for CDP..."
  until curl -s "http://localhost:$CDP_PORT/json" > /dev/null 2>&1; do sleep 0.5; done
  sleep 2
else
  echo "==> Vivaldi already running with CDP on port $CDP_PORT"
fi

echo ""
echo "==> Make sure you are logged into Slack in Vivaldi."
echo "==> Waiting for app.slack.com tab with xoxc token (polling every 3s)..."

auth_token=""
d_cookie=""
while true; do
  cdp_url=$(curl -s "http://localhost:$CDP_PORT/json" | jq -r '[.[] | select(.url | test("app\\.slack\\.com"))] | .[0].webSocketDebuggerUrl // empty')
  if [[ -z "$cdp_url" ]]; then
    echo "  no app.slack.com tab yet..."
    sleep 3
    continue
  fi

  raw_token=$(cdp_eval "$cdp_url" '{"id":2,"method":"Runtime.evaluate","params":{"expression":"(function(){try{return Object.values(JSON.parse(localStorage.localConfig_v2).teams)[0].token}catch(e){return \"\"}})()"}}')
  raw_cookies=$(cdp_eval "$cdp_url" '{"id":1,"method":"Network.getAllCookies","params":{}}')

  auth_token=$(echo "$raw_token" | jq -r '.result.result.value // empty' 2>/dev/null)
  d_cookie=$(echo "$raw_cookies" | jq -r '.result.cookies[] | select(.name=="d" and (.domain|test("slack\\.com"))) | .value' 2>/dev/null | head -1)

  echo "  auth=${auth_token:0:15} d=${d_cookie:0:15}"
  [[ "$auth_token" == xoxc-* && -n "$d_cookie" ]] && break
  sleep 3
done
echo "==> Got tokens!"

payload=$(python3 -c "import sys,json; print(json.dumps({'auth_token': sys.argv[1], 'cookie_token': sys.argv[2]}))" "$auth_token" "$d_cookie")
echo "==> Sending credentials to slack bot..."
matrix_send "$payload"

echo ""
echo "==> Done! Check the slack bot room."
