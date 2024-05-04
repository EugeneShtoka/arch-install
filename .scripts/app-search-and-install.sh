#!/bin/zsh

if pacman -Ss "^$package_name$" &> /dev/null; then
  echo "Package found in official repositories."
  sudo pacman -S $package_name

# If not found in official repos, try AUR with yay
elif yay -Ss "^$package_name$" &> /dev/null; then
  echo "Package found in AUR."
  yay -S $package_name

# Package not found in pacman or AUR 
else
  echo "Package not found in official repositories or AUR."
fi