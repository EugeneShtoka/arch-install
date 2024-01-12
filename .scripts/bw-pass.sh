bw-pass() {
  bw get item $1 | jq '.login.password'
}

bw-pass $1