#!/bin/zsh

name=$1
dir=$2

# Work projects (under ~/dev/work) use a separate Claude config dir
env_prefix=""
if [[ $dir == $HOME/dev/work || $dir == $HOME/dev/work/* ]]; then
	env_prefix="export CLAUDE_CONFIG_DIR=$HOME/.claude-work; "
fi

$SCRIPTS_PATH/wezterm-focus-or-launch.sh "Neovim: $name" /usr/bin/zsh -ilc "${env_prefix}cd '$dir' && nvim ."
