#!/bin/zsh

git clone --depth=1 https://github.com/adi1090x/rofi.git
cd rofi
chmod +x setup.sh
./setup.sh
cd ..
rm -rf rofi