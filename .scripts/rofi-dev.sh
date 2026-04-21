#!/bin/zsh

dir="$HOME/.config/rofi/launchers/type-4"
theme='style-9'

typeset -A projects
typeset -a ordered

# Load named projects from aliases-projects.sh first
nvim_project() {
	local name=$1 path=$2
	projects[$name]=$path
	ordered+=($name)
}
while IFS= read -r line; do
	eval $line
done < <(grep '^nvim_project ' $SCRIPTS_PATH/aliases-projects.sh)

# Append git repos from ~/dev and ~/dev/work not already listed
for d in $HOME/dev/*(N/) $HOME/dev/work/*(N/); do
	[[ ${d:t} == work ]] && continue
	[[ -d $d/.git ]] || continue
	[[ -v projects[${d:t}] ]] && continue
	[[ -n ${projects[(r)$d]} ]] && continue
	projects[${d:t}]=$d
	ordered+=(${d:t})
done

name=$(print -l $ordered | $SCRIPTS_PATH/rofi-run.sh -theme ${dir}/${theme}.rasi -dmenu -matching prefix)
[[ -z $name ]] && exit

proj_path=${projects[$name]}
[[ -z $proj_path ]] && exit
$SCRIPTS_PATH/nvim-open-project.sh "$name" "$proj_path"
