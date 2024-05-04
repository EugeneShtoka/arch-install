#!/bin/zsh

if pacman -Ss "^$package_name$" &> /dev/null; then
  sudo pacman -S $package_name
  echo "Package found in official repositories."
elif yay -Ss "^$package_name$" &> /dev/null; then
  yay -S $package_name
  echo "Package found in AUR."
else
  echo "Package not found in official repositories or AUR."
fi