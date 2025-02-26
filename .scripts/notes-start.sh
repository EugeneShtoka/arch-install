#!/bin/zsh

env LANGUAGE=en_GB && .scripts/ssh-init.sh && setsid obsidian &>/dev/null
