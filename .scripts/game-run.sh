#!/bin/zsh
# Run a game with the platform profile at $GAME_PROFILE (TLP's "performance"
# on AC overheats the laptop into GPU hangs), restoring the previous profile
# when the game exits.
#
#   game-run.sh steam <appid>       restores when the Steam client exits
#   game-run.sh <command> [args...]

GAME_PROFILE=${GAME_PROFILE:-balanced}
SET=(sudo -n /usr/local/bin/platform-profile-set)

saved=$(</sys/firmware/acpi/platform_profile)
$SET $GAME_PROFILE
trap '$SET $saved' EXIT
trap 'exit 1' INT TERM HUP

if [[ $1 == steam ]]; then
  # Becomes the client (and blocks) if Steam isn't running; otherwise hands
  # off to the running client and returns, so wait for that client to exit.
  steam -applaunch $2
  pidwait -x steam
else
  "$@"
fi
