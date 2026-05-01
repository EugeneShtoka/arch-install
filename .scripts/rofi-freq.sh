#!/bin/zsh
# rofi-freq.sh <menu-name> [rofi-run args...]
# Items via stdin; outputs selection; updates frecency DB.
# DB: ~/.local/share/rofi-freq/<menu-name>.json
# Frecency score: count / (1 + days_since_last_use * 0.1)
# Prunes DB entries not present in the current item list on each run.

MENU=$1; shift
DATA_DIR=$HOME/.local/share/rofi-freq
DATA_FILE=$DATA_DIR/$MENU.json
mkdir -p $DATA_DIR
[[ -f $DATA_FILE ]] || echo '{}' > $DATA_FILE

items=(${(f)"$(cat)"})
[[ ${#items} -eq 0 ]] && exit 1

now=$(date +%s)
items_json=$(printf '%s\n' $items | jq -R . | jq -s .)

# Prune: remove DB entries whose item is no longer in the current list
pruned=$(jq --argjson items "$items_json" \
  'with_entries(select(.key as $k | ($items | index($k)) != null))' \
  $DATA_FILE)
print $pruned > $DATA_FILE

# Load frecency scores into associative array
typeset -A scores
while IFS=$'\t' read -r item score; do
  scores[$item]=$score
done < <(jq -r --argjson now "$now" \
  'to_entries[] | [.key, (.value.count / (1 + (($now - .value.last_used) / 86400 * 0.1)))] | @tsv' \
  $DATA_FILE)

# Partition: known items (have a score) vs unknown (new), sort each group
known=() unknown=()
for item in $items; do
  if [[ -n ${scores[$item]} ]]; then
    known+=("${scores[$item]}"$'\t'"$item")
  else
    unknown+=("$item")
  fi
done

sorted_known=(${(f)"$(printf '%s\n' $known | sort -t$'\t' -k1 -rn | cut -f2-)"})
sorted_unknown=(${(f)"$(printf '%s\n' $unknown | sort)"})
final=($sorted_known $sorted_unknown)

sel=$(printf '%s\n' $final | $SCRIPTS_PATH/rofi-run.sh "$@" -dmenu)
[[ -z $sel ]] && exit 1

# Update DB: increment count and set last_used timestamp
updated=$(jq --arg item "$sel" --argjson now "$now" \
  'if has($item)
   then .[$item].count += 1 | .[$item].last_used = $now
   else .[$item] = {"count": 1, "last_used": $now}
   end' \
  $DATA_FILE)
print $updated > $DATA_FILE

print $sel
