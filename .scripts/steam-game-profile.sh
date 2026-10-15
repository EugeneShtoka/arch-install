#!/bin/zsh
# While a Steam game runs, hold the platform profile at $GAME_PROFILE (cooler
# than TLP's "performance" on AC, which overheats the laptop into GPU hangs).
# Restores the previous profile when the game exits. Every Steam game runs
# under `reaper SteamLaunch`, so that is what we watch for.

GAME_PROFILE=${GAME_PROFILE:-balanced}
PROFILE=/sys/firmware/acpi/platform_profile
SET=(sudo -n /usr/local/bin/platform-profile-set)

saved=""
while sleep 5; do
  if pgrep -f '^\S*reaper SteamLaunch' >/dev/null; then
    current=$(<$PROFILE)
    [[ -z $saved ]] && saved=$current && echo "game started, $current -> $GAME_PROFILE"
    # Re-assert: TLP resets the profile on AC plug/unplug.
    [[ $current != $GAME_PROFILE ]] && $SET $GAME_PROFILE
  elif [[ -n $saved ]]; then
    echo "game exited, restoring $saved"
    $SET $saved
    saved=""
  fi
done
