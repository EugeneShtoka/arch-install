#!/bin/zsh
# mxctl-notify.sh — notification processor for mxctl
# stdin:  JSON {"event_id","room_id","room_name","sender","body","msg_type","ts"}
# stdout: JSON action, or nothing to suppress notification

input=$(cat)

sender=$(printf '%s' "$input" | jq -r '.sender // empty')
[[ -z "$sender" ]] && exit 0

# Suppress own messages across all bridges
self_ids=(
    "@eugene:matrix.cloud-surf.com"
    "@slack_t01k2d5tcac-u08fys2bbhb:matrix.cloud-surf.com"
    "@whatsapp_bg_359884650326:matrix.cloud-surf.com"
    "@whatsapp_il_972545347450:matrix.cloud-surf.com"
    "@whatsapp_il_lid-273173559930881:matrix.cloud-surf.com"
    "@whatsapp_bg_lid-273173559930881:matrix.cloud-surf.com"
    "@whatsapp_bg_lid-181222537961625:matrix.cloud-surf.com"
)
#for id in "${self_ids[@]}"; do
#    [[ "$sender" == "$id" ]] && exit 0
#done

room=$(printf '%s' "$input" | jq -r '.room_name // empty')
body=$(printf '%s' "$input" | jq -r '.body // empty')
[[ -z "$body" ]] && exit 0

# Trim sender to local part (@user:server → user)
display="${sender#@}"
display="${display%%:*}"

title="${room} · ${display}"
[[ "${#body}" -gt 200 ]] && body="${body:0:200}…"

jq -n --arg title "$title" --arg body "$body" \
    '{"type":"notify","title":$title,"body":$body}'
