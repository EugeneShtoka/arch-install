#!/bin/zsh

package=$1
    IFS=$'\n'
    searchResults=$(yay -Ss $package)
    packages=$(echo $searchResults | awk 'NR % 2 == 1')
    names=$(echo $packages | awk '{print $1}')
    names_arr=${(f)$names}
    versions=${(f)$(echo $packages | awk '{print $2}')}
    descriptions=${(f)$(echo $searchResults | awk 'NR % 2 == 0')}
    for i in {1..$(echo $names | wc -l)}; do
      echo ${names[i]} ${versions[i]} ${descriptions[i]}
    done

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
    echo "Package not found in official repositories or AUR."
    searchResults=$(yay -Ss $package)
    echo $searchResults
    echo $(echo $searchResults | awk 'NR % 2 == 0')
  fi
fi