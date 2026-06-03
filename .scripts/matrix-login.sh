#!/bin/zsh
# Register or log in to matrix.cloud-surf.com and store the token in the keyring.
# Usage:
#   matrix-login.sh register   — register @eugene (needs registration token)
#   matrix-login.sh login      — log in with existing account

MATRIX_BASE="https://matrix.cloud-surf.com"
MATRIX_USER="eugene"
MATRIX_DOMAIN="matrix.cloud-surf.com"

mode="${1:-login}"

echo -n "Password: "
read -rs password
echo

if [[ "$mode" == "register" ]]; then
  echo -n "Registration token: "
  read -r reg_token
  echo

  resp=$(curl -s -X POST "$MATRIX_BASE/_matrix/client/v3/register" \
    -H "Content-Type: application/json" \
    -d "{
      \"username\": \"${MATRIX_USER}\",
      \"password\": $(python3 -c "import sys,json; print(json.dumps(sys.argv[1]))" "$password"),
      \"auth\": {\"type\": \"m.login.registration_token\", \"token\": \"${reg_token}\"},
      \"inhibit_login\": false
    }")
else
  resp=$(curl -s -X POST "$MATRIX_BASE/_matrix/client/v3/login" \
    -H "Content-Type: application/json" \
    -d "{
      \"type\": \"m.login.password\",
      \"identifier\": {\"type\": \"m.id.user\", \"user\": \"${MATRIX_USER}\"},
      \"password\": $(python3 -c "import sys,json; print(json.dumps(sys.argv[1]))" "$password"),
      \"device_id\": \"laptop-scripts\"
    }")
fi

token=$(echo "$resp" | jq -r '.access_token // empty')
if [[ -z "$token" ]]; then
  echo "ERROR: $(echo "$resp" | jq -r '.error // .errcode // "unknown error"')"
  exit 1
fi

echo -n "$token" | secret-tool store --label="Matrix token for @${MATRIX_USER}:${MATRIX_DOMAIN}" \
  service "matrix" username "eugene"

echo "Token stored in keyring."
echo "User: @${MATRIX_USER}:${MATRIX_DOMAIN}"
