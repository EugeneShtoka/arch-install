#!/bin/zsh
# Run a game with the platform profile at $GAME_PROFILE (TLP's "performance"
# on AC overheats the laptop into GPU hangs), restoring the previous profile
# once the last running game exits.
#
#   game-run.sh steam <appid>
#   game-run.sh <command> [args...]

GAME_PROFILE=${GAME_PROFILE:-balanced}
PROFILE=/sys/firmware/acpi/platform_profile
STATE=${XDG_RUNTIME_DIR:-/tmp}/game-profile
SET=(sudo -n /usr/local/bin/platform-profile-set)

mkdir -p $STATE
[[ -e $STATE/saved ]] || cp $PROFILE $STATE/saved
touch $STATE/$$
$SET $GAME_PROFILE

restore() {
  rm -f $STATE/$$
  # Another game still running (its wrapper alive) keeps the game profile.
  for f in $STATE/<->(N); do kill -0 ${f:t} 2>/dev/null && return || rm -f $f; done
  $SET $(<$STATE/saved) && rm -f $STATE/saved
}
trap restore EXIT
trap 'exit 1' INT TERM HUP

if [[ $1 == steam ]]; then
  # -applaunch hands off to a running client and returns at once (or becomes
  # the client if Steam isn't running), so wait on the game's reaper instead.
  setsid steam -applaunch $2 &>/dev/null &!
  pattern="reaper SteamLaunch AppId=$2 "
  # Allow time for Steam to start, update the game, and compile shaders.
  for _ in {1..600}; do pgrep -f $pattern >/dev/null && break; sleep 1; done
  pidwait -f $pattern
else
  "$@"
fi
