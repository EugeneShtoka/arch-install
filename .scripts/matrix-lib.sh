#!/bin/zsh
# Sourced by matrix bridge relogin scripts.
# Provides: matrix_connect <bot_name>, matrix_send <body>
# Sets: MATRIX_TOKEN, BOT_ID, BOT_ROOM, BOT_ROOM_ENC

MATRIX_BASE="https://matrix.cloud-surf.com"
MATRIX_USER="@eugene:matrix.cloud-surf.com"

_matrix_urlencode() {
  python3 -c "import sys,urllib.parse; print(urllib.parse.quote(sys.argv[1], safe=''))" "$1"
}

# Validates auth token, checks bot exists, resolves DM room.
# Sets MATRIX_TOKEN, BOT_ID, BOT_ROOM, BOT_ROOM_ENC.
matrix_connect() {
  local bot_name="$1"
  [[ -z "$bot_name" ]] && { echo "ERROR: matrix_connect: bot name required" >&2; return 1; }

  MATRIX_TOKEN=$(secret-tool lookup service "matrix" username "eugene")
  [[ -z "$MATRIX_TOKEN" ]] && { echo "ERROR: Matrix token not found in keyring" >&2; return 1; }

  local whoami_resp
  whoami_resp=$(curl -s "$MATRIX_BASE/_matrix/client/v3/account/whoami" \
    -H "Authorization: Bearer $MATRIX_TOKEN")
  if echo "$whoami_resp" | jq -e '.errcode' > /dev/null 2>&1; then
    echo "ERROR: Matrix token is stale or invalid ($(echo "$whoami_resp" | jq -r '.error // .errcode'))" >&2
    return 1
  fi

  BOT_ID="@${bot_name}:matrix.cloud-surf.com"
  local bot_id_enc
  bot_id_enc=$(_matrix_urlencode "$BOT_ID")

  local profile_resp
  profile_resp=$(curl -s "$MATRIX_BASE/_matrix/client/v3/profile/$bot_id_enc")
  if echo "$profile_resp" | jq -e '.errcode' > /dev/null 2>&1; then
    echo "ERROR: Bot $BOT_ID not found ($(echo "$profile_resp" | jq -r '.error // .errcode'))" >&2
    return 1
  fi

  BOT_ROOM=$(curl -s \
    "$MATRIX_BASE/_matrix/client/v3/user/$MATRIX_USER/account_data/m.direct" \
    -H "Authorization: Bearer $MATRIX_TOKEN" \
    | jq -r --arg bot "$BOT_ID" '.[$bot][0] // empty')

  if [[ -z "$BOT_ROOM" ]]; then
    echo "ERROR: No DM room found with $BOT_ID" >&2
    return 1
  fi

  BOT_ROOM_ENC=$(_matrix_urlencode "$BOT_ROOM")
  echo "==> Matrix: token valid, bot $BOT_ID found, room $BOT_ROOM"
}

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
