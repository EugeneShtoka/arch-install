#!/bin/zsh

dir="$HOME/.config/rofi/launchers/type-4"
theme='style-9'

typeset -A projects

for d in $HOME/dev/*(N/); do
	[[ ${d:t} == work ]] && continue
	projects[${d:t}]=$d
done

for d in $HOME/dev/work/*(N/); do
	projects[${d:t}]=$d
done

name=$(print -l ${(k)projects} | sort | rofi -theme ${dir}/${theme}.rasi -dmenu -matching prefix)
[[ -z $name ]] && exit

path=${projects[$name]}
cmd="wezterm cli set-tab-title '$name' && cd '$path' && nvim . && clr"

wezterm cli spawn -- zsh -ic $cmd 2>/dev/null || wezterm start -- zsh -ic $cmd
