#!/bin/zsh

nvim_project() {
	local name=$1
	local path=$2
	alias $name="wezterm cli set-tab-title '$name' && cd '$path' && nvim . && clr"
}

for dir in $HOME/dev/*(N/); do
	[[ ${dir:t} == work ]] && continue
	nvim_project ${dir:t} $dir
done

for dir in $HOME/dev/work/*(N/); do
	nvim_project ${dir:t} $dir
done
