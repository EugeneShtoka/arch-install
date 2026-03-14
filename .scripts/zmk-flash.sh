#!/bin/zsh

REPO="EugeneShtoka/zmk-config"
MOUNT_POINT="/tmp/qmk"
TEMP_DIR=$(mktemp -d /tmp/zmk_XXXXXX)
BOOTLOADER_LABEL="${BOOTLOADER_LABEL:-KEEBART}"
BT_NAME_PATTERN="[Pp]iantor"

cleanup() {
    mountpoint -q $MOUNT_POINT 2>/dev/null && sudo umount $MOUNT_POINT 2>/dev/null
    rm -rf $TEMP_DIR
}
trap cleanup EXIT

bt_disconnect() {
    local mac=$(bluetoothctl devices | grep -i "$BT_NAME_PATTERN" | awk '{print $2}' | head -1)
    [[ -n $mac ]] || { echo "Piantor Pro BT not found in paired devices, skipping disconnect"; return; }
    echo "Disconnecting Piantor Pro BT ($mac)..."
    bluetoothctl disconnect $mac
}

bt_scan_and_connect() {
    echo "Scanning for Piantor Pro BT (10s)..."
    bluetoothctl scan on &
    local scan_pid=$!
    sleep 10
    bluetoothctl scan off
    wait $scan_pid 2>/dev/null

    local mac=$(bluetoothctl devices | grep -i "$BT_NAME_PATTERN" | awk '{print $2}' | head -1)
    if [[ -n $mac ]]; then
        echo "Connecting to Piantor Pro BT ($mac)..."
        bluetoothctl connect $mac
    else
        echo "Piantor Pro BT not found after scan" >&2
    fi
}

wait_for_bootloader() {
    echo "Waiting for bootloader ($BOOTLOADER_LABEL)..." >&2
    for i in {1..60}; do
        local dev=$(readlink -f /dev/disk/by-label/$BOOTLOADER_LABEL 2>/dev/null)
        [[ -b $dev ]] && echo $dev && return
        sleep 1
    done
    echo "Error: bootloader device not found after 60s" >&2
    exit 1
}

flash() {
    local fw=$1
    local label=$2

    local dev=$(wait_for_bootloader)
    echo "Mounting $dev..."
    sudo mount $dev $MOUNT_POINT || { echo "Error: failed to mount $dev" >&2; exit 1; }

    echo "Flashing $label..."
    sudo cp $fw $MOUNT_POINT/ || { sudo umount $MOUNT_POINT 2>/dev/null; echo "Error: failed to copy firmware" >&2; exit 1; }
    sync

    local waited=0
    while mountpoint -q $MOUNT_POINT 2>/dev/null && (( waited++ < 15 )); do sleep 1; done
    sudo umount $MOUNT_POINT 2>/dev/null
    echo "$label done"
}

# Download latest artifact
echo "Fetching latest run from $REPO..."
run_id=$(gh run list -R $REPO --status success -L 1 --json databaseId -q '.[0].databaseId')
echo "Run: $run_id"

gh run download $run_id -R $REPO -D $TEMP_DIR -n firmware
echo "Downloaded:"
find $TEMP_DIR -name "*.uf2" | sort

sudo mkdir -p $MOUNT_POINT

left_reset=$(find $TEMP_DIR -name "*.uf2" | grep settings_reset | grep left)
left_fw=$(find $TEMP_DIR -name "*.uf2" | grep -v settings_reset | grep left)
right_reset=$(find $TEMP_DIR -name "*.uf2" | grep settings_reset | grep right)
right_fw=$(find $TEMP_DIR -name "*.uf2" | grep -v settings_reset | grep right)

# Flash left
echo "\n=== LEFT KEYBOARD ==="

if [[ -n $left_reset ]]; then
    echo "Double-tap reset on LEFT keyboard..."
    flash $left_reset "left settings_reset"
fi

echo "Double-tap reset on LEFT keyboard..."
flash $left_fw "left firmware"

# Flash right
echo "\n=== RIGHT KEYBOARD ==="

if [[ -n $right_reset ]]; then
    echo "Double-tap reset on RIGHT keyboard..."
    flash $right_reset "right settings_reset"
fi

echo "Double-tap reset on RIGHT keyboard..."
flash $right_fw "right firmware"

echo "\nDone! Both halves updated."
