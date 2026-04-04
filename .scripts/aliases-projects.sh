#!/bin/zsh

nvim_project() {
	local name=$1
	local path=$2
	alias $name="$SCRIPTS_PATH/nvim-open-project.sh '$name' '$path'"
}

nvim_project work-be          $HOME/dev/work/exbetz-be-api
nvim_project system           $HOME
nvim_project nvim-config      $HOME/.config/nvim
nvim_project i3-config        $HOME/.config/i3
nvim_project terminal-config  $HOME/.config/wezterm
nvim_project file-browser     $HOME/.config/yazi
nvim_project keyboard         $HOME/dev/zmk-config
nvim_project figoro           $HOME/dev/figoro
nvim_project blog             $HOME/dev/blog
