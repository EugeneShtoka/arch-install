#!/bin/zsh
setsid zsh -c "env LANGUAGE=en_GB && ~/.scripts/ssh-init.sh && obsidian" &>/dev/null

