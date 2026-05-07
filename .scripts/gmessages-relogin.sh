#!/bin/zsh

source ~/.scripts/matrix-lib.sh
matrix_connect "gmessagesbot" || exit 1

SOCKS_PORT=1080
CDP_PORT=9222
GOOGLE_URL="https://accounts.google.com/AccountChooser?continue=https://messages.google.com/web/config"
COOKIE_KEYS=(SID HSID SSID OSID APISID SAPISID __Secure-1PSIDTS)

echo "==> Enabling TCP forwarding on VPS..."
ssh -n hetzner "sudo sed -i 's/AllowTcpForwarding no/AllowTcpForwarding yes/' /etc/ssh/sshd_config.d/hardening.conf && sudo systemctl reload ssh" || true
stty sane 2>/dev/null

echo "==> Starting SSH SOCKS tunnel..."
if ss -tlnp 2>/dev/null | grep -q ":${SOCKS_PORT} "; then
  echo "    (tunnel already running, reusing)"
  SSH_PID=""
else
  ssh -n -D $SOCKS_PORT -N hetzner &
  SSH_PID=$!
  sleep 2
fi

cleanup() {
  echo "==> Cleaning up tunnel..."
  [[ -n "$SSH_PID" ]] && kill $SSH_PID 2>/dev/null
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
echo "==> Waiting for login cookies (polling every 3s)..."

raw=""
while true; do
  raw=$(echo '{"id":1,"method":"Network.getAllCookies","params":{}}' | websocat -1 "$cdp_url" 2>/dev/null)
  sid=$(echo "$raw" | jq -r '.result.cookies[] | select(.name=="SID" and (.domain|test("google"))) | .value' 2>/dev/null | head -1)
  [[ -n "$sid" ]] && break
  sleep 3
done
echo "==> Logged in!"

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
