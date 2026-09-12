#!/bin/bash
source $SCRIPTS_PATH/notify-lib.sh

IFACE=wlan0
ROFI_DIR="$HOME/.config/rofi/launchers/type-4"
ROFI_THEME='style-9'

# UI mode: tui when run from a terminal, gui otherwise.
# Override with --tui/--gui or WIFI_MENU=tui|gui
MODE=${WIFI_MENU:-}
case "$1" in
    --tui) MODE=tui ;;
    --gui) MODE=gui ;;
    --off) MODE=${MODE:-none}; ACTION=off ;;
    --status) ACTION=status ;;
    "") ;;
    *) echo "Usage: ${0##*/} [--tui|--gui|--off|--status]" >&2; exit 1 ;;
esac
[ -n "$MODE" ] || { [ -t 0 ] && [ -t 1 ] && MODE=tui || MODE=gui; }

strip_ansi() { sed 's/\x1b\[[0-9;]*m//g'; }

radio_blocked() {
    rfkill list wifi | grep -q 'Soft blocked: yes'
}

radio_on() {
    radio_blocked || return 0
    echo "Wi-Fi is off - turning it on..." >&2
    sudo rfkill unblock wifi
    for i in {1..20}; do
        iwctl station $IFACE show &>/dev/null && return 0
        sleep 0.25
    done
    echo "Error: $IFACE did not come up after unblocking." >&2
    exit 1
}

radio_off() {
    iwctl station $IFACE disconnect &>/dev/null
    sudo rfkill block wifi
    notify_send "Wi-Fi" "Disconnected and turned off"
    echo "Wi-Fi disconnected and turned off."
}

scan() {
    iwctl station $IFACE scan &>/dev/null
    for i in {1..20}; do
        iwctl station $IFACE show 2>/dev/null | strip_ansi \
            | grep -q 'Scanning[[:space:]]*no' && return 0
        sleep 0.25
    done
}

connected_ssid() {
    iwctl station $IFACE show 2>/dev/null | strip_ansi \
        | awk '/Connected network/ { sub(/^[[:space:]]*Connected network[[:space:]]+/,""); sub(/[[:space:]]+$/,""); print }'
}

# name|security, in signal order as reported by iwd
list_available() {
    iwctl station $IFACE get-networks 2>/dev/null | strip_ansi | awk '
        /Network name/ { sec = index($0, "Security"); next }
        !sec || !NF { next }
        {
            name = substr($0, 1, sec - 1); rest = substr($0, sec)
            gsub(/^[[:space:]]*>?[[:space:]]*/, "", name); gsub(/[[:space:]]+$/, "", name)
            split(rest, r, " ")
            if (name != "" && name !~ /^-+$/) print name "|" r[1]
        }'
}

list_known() {
    iwctl known-networks list 2>/dev/null | strip_ansi | awk '
        /Security/ { sec = index($0, "Security"); next }
        !sec || !NF { next }
        {
            name = substr($0, 1, sec - 1)
            gsub(/^[[:space:]]*/, "", name); gsub(/[[:space:]]+$/, "", name)
            if (name != "" && name !~ /^-+$/) print name
        }'
}

# menu <prompt> <<< lines ; bold marked with \x01 ... \x02
menu() {
    local prompt="$1" input; input=$(cat)
    if [ "$MODE" = tui ]; then
        printf '%s\n' "$input" \
            | sed $'s/\x01/\033[1m/g; s/\x02/\033[0m/g' \
            | fzf --ansi --reverse --height=60% --prompt="$prompt " --no-sort --no-info
    else
        # escape pango specials before turning the bold markers into tags,
        # then undo the escaping on whatever rofi hands back
        printf '%s\n' "$input" \
            | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g; s/\x01/<b>/g; s/\x02/<\/b>/g' \
            | $SCRIPTS_PATH/rofi-run.sh -theme "$ROFI_DIR/$ROFI_THEME.rasi" -dmenu -markup-rows \
                  -i -p "$prompt" -theme-str 'inputbar { enabled: false; }' \
            | sed 's|</\?b>||g; s/&lt;/</g; s/&gt;/>/g; s/&amp;/\&/g'
    fi
}

ask_password() {
    local ssid="$1" pw
    if [ "$MODE" = tui ]; then
        read -rsp "Password for \"$ssid\": " pw </dev/tty; echo >&2
    else
        pw=$($SCRIPTS_PATH/rofi-run.sh -theme "$ROFI_DIR/$ROFI_THEME.rasi" -dmenu -password \
                 -p "Password for $ssid" -theme-str 'listview { enabled: false; }')
    fi
    printf '%s' "$pw"
}

connect() {
    local ssid="$1" security="$2" known="$3" pw out
    if [ "$known" = yes ] || [ "$security" = open ]; then
        out=$(iwctl station $IFACE connect "$ssid" 2>&1 | strip_ansi)
    elif [ "$security" = psk ]; then
        pw=$(ask_password "$ssid")
        [ -n "$pw" ] || { echo "No password entered. Aborting." >&2; exit 1; }
        out=$(iwctl --passphrase "$pw" station $IFACE connect "$ssid" 2>&1 | strip_ansi)
    else
        notify_send "Wi-Fi" "\"$ssid\" uses $security - configure it manually"
        echo "\"$ssid\" uses $security, which this script does not handle." >&2
        exit 1
    fi

    sleep 1
    if [ "$(connected_ssid)" = "$ssid" ]; then
        notify_send "Wi-Fi" "Connected to $ssid"
        echo "Connected to $ssid."
    else
        notify_send "Wi-Fi" "Failed to connect to $ssid"
        echo "Failed to connect to $ssid. ${out:+$out}" >&2
        exit 1
    fi
}

# --- non-menu actions -------------------------------------------------------
case "$ACTION" in
    off)    radio_off; exit 0 ;;
    status)
        if radio_blocked; then echo "Wi-Fi: off"
        else
            cur=$(connected_ssid)
            echo "Wi-Fi: on${cur:+ - connected to $cur}"
        fi
        exit 0 ;;
esac

# --- build the menu ---------------------------------------------------------
radio_on
scan

ACTIVE=$(connected_ssid)
mapfile -t KNOWN < <(list_known)

declare -A IS_KNOWN
for n in "${KNOWN[@]}"; do IS_KNOWN["$n"]=yes; done

declare -A SEC_OF ENTRY_SSID
known_rows=() other_rows=()

while IFS='|' read -r name sec; do
    [ -n "$name" ] || continue
    SEC_OF["$name"]=$sec
    if [ "$name" = "$ACTIVE" ]; then
        row=$'\x01'"$name"$'\x02'"  ✓ connected"
        known_rows=("$row" "${known_rows[@]}")
    elif [ "${IS_KNOWN[$name]}" = yes ]; then
        row=$'\x01'"$name"$'\x02'
        known_rows+=("$row")
    elif [ "$sec" = open ]; then
        row="$name  ·  open"
        other_rows+=("$row")
    else
        row="$name  ·  password needed"
        other_rows+=("$row")
    fi
    ENTRY_SSID["$(printf '%s' "$row" | tr -d '\001\002')"]=$name
done < <(list_available)

if [ ${#known_rows[@]} -eq 0 ] && [ ${#other_rows[@]} -eq 0 ]; then
    echo "No Wi-Fi networks found. Check 'systemctl status iwd.service'." >&2
    exit 1
fi

rows=("${known_rows[@]}" "${other_rows[@]}")
[ -n "$ACTIVE" ] && rows+=("Disconnect")
rows+=("Turn Wi-Fi off")

SELECTED=$(printf '%s\n' "${rows[@]}" | menu "Wi-Fi")
SELECTED=$(printf '%s' "$SELECTED" | tr -d '\001\002')

[ -n "$SELECTED" ] || { echo "Nothing selected." >&2; exit 0; }

case "$SELECTED" in
    "Turn Wi-Fi off") radio_off; exit 0 ;;
    "Disconnect")
        iwctl station $IFACE disconnect
        notify_send "Wi-Fi" "Disconnected"
        echo "Disconnected."
        exit 0 ;;
esac

SSID=${ENTRY_SSID["$SELECTED"]}
[ -n "$SSID" ] || { echo "Could not resolve selection: $SELECTED" >&2; exit 1; }
[ "$SSID" = "$ACTIVE" ] && { echo "Already connected to $SSID."; exit 0; }

connect "$SSID" "${SEC_OF[$SSID]}" "${IS_KNOWN[$SSID]:-no}"
