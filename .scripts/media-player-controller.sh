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

    echo "VLC current status: $CURRENT_STATUS"

    case "$CURRENT_STATUS" in
        "Playing")
            echo "VLC is Playing."
            echo "==> ACTION: Triggering PAUSE."
            # Call your pause script:
            # if [ -x "$SCRIPT_TO_PAUSE_MUSIC" ]; then
            #     "$SCRIPT_TO_PAUSE_MUSIC"
            # else
            #     echo "Pause script not found. Sending D-Bus Pause directly."
            dbus-send --session --type=method_call --dest="$DBUS_DEST" "$DBUS_PATH" \
                      "$DBUS_PLAYER_INTERFACE.Pause" >/dev/null
            # fi
            ;;
        "Paused")
            echo "VLC is Paused."
            echo "==> ACTION: Triggering PLAY (Resume)."
            # Call your resume script:
            # if [ -x "$SCRIPT_TO_RESUME_MUSIC" ]; then
            #     "$SCRIPT_TO_RESUME_MUSIC"
            # else
            #     echo "Resume script not found. Sending D-Bus Play directly."
            dbus-send --session --type=method_call --dest="$DBUS_DEST" "$DBUS_PATH" \
                      "$DBUS_PLAYER_INTERFACE.Play" >/dev/null
            # fi
            ;;
        "Stopped")
            echo "VLC is Stopped."
            echo "==> ACTION: Trigger your script to START PLAYING music (re-load defined source)."
            # This implies your "play" script should handle loading music into an
            # already running but "Stopped" VLC instance.
            # Example using your script:
            # if [ -x "$SCRIPT_TO_START_PLAYING_MUSIC" ]; then
            #     "$SCRIPT_TO_START_PLAYING_MUSIC"
            # else
            #     echo "Start script not found. Sending D-Bus OpenUri and Play directly."
            #     # Ensure MUSIC_SOURCE_TO_PLAY_WHEN_STOPPED is set and is an absolute path
            #     if [ -n "$MUSIC_SOURCE_TO_PLAY_WHEN_STOPPED" ] && [ -e "$MUSIC_SOURCE_TO_PLAY_WHEN_STOPPED" ]; then
            #         dbus-send --session --type=method_call --dest="$DBUS_DEST" "$DBUS_PATH" \
            #                   "$DBUS_PLAYER_INTERFACE.OpenUri" "string:file://$MUSIC_SOURCE_TO_PLAY_WHEN_STOPPED" >/dev/null
            #         sleep 0.3 # Brief pause for OpenUri to reliably take effect
            #         dbus-send --session --type=method_call --dest="$DBUS_DEST" "$DBUS_PATH" \
            #                   "$DBUS_PLAYER_INTERFACE.Play" >/dev/null
            #     else
            #         echo "Error: MUSIC_SOURCE_TO_PLAY_WHEN_STOPPED not set or invalid for direct D-Bus OpenUri."
            #     fi
            # fi
            ;;
        *)
            echo "VLC is in an unhandled D-Bus state: '$CURRENT_STATUS'."
            echo "==> ACTION: Attempting a generic PlayPause toggle as a fallback."
            dbus-send --session --type=method_call --dest="$DBUS_DEST" "$DBUS_PATH" \
                      "$DBUS_PLAYER_INTERFACE.PlayPause" >/dev/null
            ;;
    esac
fi

echo "Script decision logic finished."