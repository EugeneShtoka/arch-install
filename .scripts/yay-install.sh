#!/bin/zsh

sudo pacman -S --needed git base-devel
rm -rf yay-bin
git clone https://aur.archlinux.org/yay-bin.git
cd yay-bin
yes | makepkg -si
cd ../
rm -rf yay-bin
