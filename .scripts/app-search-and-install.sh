#!/bin/zsh

install() {
  package=$1
  $SCRIPTS_PATH/auto-yay.sh $package
  if [[ $(grep -c "\$SCRIPTS_PATH/auto-yay.sh $package" "$SCRIPTS_PATH/apps-install-yay.sh") -eq 0 ]]; then
    echo "\$SCRIPTS_PATH/auto-yay.sh $package" >> $SCRIPTS_PATH/apps-install-yay.sh
  fi
}

package=$1

aur=$(yay -Ss "^$package$" | wc -l)
if [[ $aur -gt 0 ]]; then
  install $package
else
  SAVEIFS=$IFS
  IFS=$'\n'
  searchResults=$(yay -Ss $package)
  packages=$(echo $searchResults | awk 'NR % 2 == 1')
  names=($(echo $packages | awk '{print $1}'))
  versions=($(echo $packages | awk '{print $2}'))
  descriptions=($(echo $searchResults | awk 'NR % 2 == 0'))
  found=()
  if [[ ${#names[@]} -gt 0 ]]; then  
    for (( i=${#names[@]}; i>=1; i-- )); do
        found+=("${names[i]} ${versions[i]} ${descriptions[i]}")
    done
    dir="$HOME/.config/rofi/launchers/type-4"
    theme='style-9-wide'
    choice=$(printf '%s\n' "${found[@]}" | rofi -theme ${dir}/${theme}.rasi -dmenu)
    if [[ -n $choice ]]; then
      install "${$(echo $choice | awk '{print $1}')##*/}"
    else
      echo "Haven't selected any package"
    fi
  else
    echo "Haven't found any package matching $package"
  fi
fi
