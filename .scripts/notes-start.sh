#!/bin/zsh
setsid zsh -c "env LANGUAGE=en_GB && /home/eugene/.scripts/ssh-init.sh ssh-add -l && obsidian" &>/dev/null

