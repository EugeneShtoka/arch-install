#!/bin/zsh

package=$1
official=$(pacman -Ss "^$package$" | wc -l)
if [[ $official -gt 0 ]]; then
  #sudo pacman -S $package
  echo "Package $package found in official repositories."
else
  aur=$(yay -Ss "^$package$" | wc -l)
  if [[ $aur -gt 0 ]]; then
    #$SCRIPTS_PATH/auto-yay.sh $package
    echo "Package $package found in AUR."
  else

    SAVEIFS=$IFS
    IFS=$'\n'
    searchResults=$(yay -Ss $package)
    packages=$(echo $searchResults | awk 'NR % 2 == 1')
    names=($(echo $packages | awk '{print $1}'))
    versions=($(echo $packages | awk '{print $2}'))
    descriptions=($(echo $searchResults | awk 'NR % 2 == 0'))
    found=()
    for (( i=${#names[@]}; i>=1; i-- )); do
        found+=("${names[i]} ${versions[i]} ${descriptions[i]}")
    done
    dir="$HOME/.config/rofi/launchers/type-4"
	theme='style-9a'
	choice=$(printf '%s\n' "${found[@]}" | rofi -theme ${dir}/${theme}.rasi -dmenu -matching prefix)
  fi
fi

IFS=$SAVEIFS   # Restore original IFS
