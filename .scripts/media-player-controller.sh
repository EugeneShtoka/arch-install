#!/bin/bash

# --- D-Bus Configuration for VLC ---
DBUS_DEST="org.mpris.MediaPlayer2.vlc"
DBUS_PATH="/org/mpris/MediaPlayer2"
DBUS_PLAYER_INTERFACE="org.mpris.MediaPlayer2.Player"
DBUS_PROPERTIES_INTERFACE="org.freedesktop.DBus.Properties"

echo "Attempting to get VLC playback status via D-Bus..."

STATUS_RAW_OUTPUT=$(dbus-send --session --print-reply --dest="$DBUS_DEST" "$DBUS_PATH" \
                    "$DBUS_PROPERTIES_INTERFACE.Get" \
                    string:"$DBUS_PLAYER_INTERFACE" string:"PlaybackStatus" 2>&1)
DBUS_GET_STATUS_EXIT_CODE=$?

if [ $DBUS_GET_STATUS_EXIT_CODE -ne 0 ]; then
    echo "Error getting VLC status (exit code $DBUS_GET_STATUS_EXIT_CODE)."
    echo "D-Bus output: $STATUS_RAW_OUTPUT"
    echo "==> ACTION: Assuming VLC is not playing. Trigger your script to START PLAYING music."
else
    dbus-send --session --type=method_call --dest="$DBUS_DEST" "$DBUS_PATH" "$DBUS_PLAYER_INTERFACE.PlayPause" >/dev/null
fi

echo "Script decision logic finished."