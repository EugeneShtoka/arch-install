#!/bin/zsh

nvim_project() {
	local name=$1
	local path=$2
	alias $name="$SCRIPTS_PATH/nvim-open-project.sh '$name' '$path'"
}

nvim_project system               $HOME
nvim_project i3-config            $HOME/.config/i3
nvim_project nvim-config          $HOME/.config/nvim
nvim_project terminal-config      $HOME/.config/wezterm
nvim_project file-browser-config  $HOME/.config/yazi
