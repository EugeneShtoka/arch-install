#!/bin/zsh

package=$1
if pacman -Ss "^$package$" &> /dev/null; then
  sudo pacman -S $package
  echo "Package $package found in official repositories."
elif yay -Ss "^$package$" &> /dev/null; then
  yayi $package
  echo "Package $package found in AUR."
else
  echo "Package not found in official repositories or AUR."
fi