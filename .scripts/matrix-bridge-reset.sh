#!/bin/zsh

SERVER="https://matrix.cloud-surf.com"
DOMAIN="matrix.cloud-surf.com"
APPSERVICE_TOKEN="656a56520c3b6175e98ff0ad94f15875609f8a9a4b22600bdc7e156ca04784a0"

ALL_BOTS=(whatsapp-bg-bot whatsapp-il-bot gmessagesbot metabot slackbot telegrambot linkedinbot signalbot)

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

# Fetch full m.direct once
mdirect=$(curl -s "${SERVER}/_matrix/client/v3/user/@eugene:${DOMAIN}/account_data/m.direct" \
  -H "Authorization: Bearer $TOKEN")

for bot in "${ALL_BOTS[@]}"; do
  echo "--- $bot ---"

  rooms=$(echo "$mdirect" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    for r in data.get('@${bot}:${DOMAIN}', []): print(r)
except: pass
" 2>/dev/null)

  if [[ -z "$rooms" ]]; then
    echo "  no rooms found"
    continue
  fi

  for room in ${(f)rooms}; do
    echo "  $room: sending logout..."
    curl -s -X PUT "${SERVER}/_matrix/client/v3/rooms/${room}/send/m.room.message/$(txn)" \
      -H "Authorization: Bearer $TOKEN" \
      -H "Content-Type: application/json" \
      -d '{"msgtype":"m.text","body":"logout"}' >/dev/null
    sleep 1

    echo "  $room: leaving..."
    curl -s -X POST "${SERVER}/_matrix/client/v3/rooms/${room}/leave" \
      -H "Authorization: Bearer $TOKEN" \
      -H "Content-Type: application/json" \
      -d '{}' >/dev/null

    echo "  $room: forgetting..."
    curl -s -X POST "${SERVER}/_matrix/client/v3/rooms/${room}/forget" \
      -H "Authorization: Bearer $TOKEN" \
      -H "Content-Type: application/json" \
      -d '{}' >/dev/null
  done
done

echo ""
echo "Clearing m.direct account data..."
mdirect_cleaned=$(echo "$mdirect" | python3 -c "
import sys, json
data = json.load(sys.stdin)
bots = [$(printf "'@%s:${DOMAIN}'," "${ALL_BOTS[@]}")]
for b in bots: data.pop(b, None)
print(json.dumps(data))
")
curl -s -X PUT "${SERVER}/_matrix/client/v3/user/@eugene:${DOMAIN}/account_data/m.direct" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "$mdirect_cleaned" >/dev/null

echo ""
echo "=== Wiping bridge DBs on VPS ==="
ssh hetzner "
  set -e
  echo 'Stopping bridge services...'
  sudo systemctl stop mautrix-gmessages mautrix-linkedin mautrix-meta mautrix-signal mautrix-slack mautrix-telegram mautrix-whatsapp-bg mautrix-whatsapp-il

  echo 'Deleting bridge DBs...'
  sudo rm -f \
    /var/lib/mautrix-gmessages/bridge.db \
    /var/lib/mautrix-linkedin/bridge.db \
    /var/lib/mautrix-meta/bridge.db \
    /var/lib/mautrix-slack/bridge.db \
    /var/lib/mautrix-whatsapp-bg/bridge.db \
    /var/lib/mautrix-whatsapp-il/bridge.db

  echo 'Restarting bridge services...'
  sudo systemctl start mautrix-gmessages mautrix-linkedin mautrix-meta mautrix-signal mautrix-slack mautrix-telegram mautrix-whatsapp-bg mautrix-whatsapp-il

  echo 'Bridge services status:'
  sudo systemctl is-active mautrix-gmessages mautrix-linkedin mautrix-meta mautrix-signal mautrix-slack mautrix-telegram mautrix-whatsapp-bg mautrix-whatsapp-il
"

echo ""
echo "Done. Run matrix-bridge-login.sh to start fresh."
