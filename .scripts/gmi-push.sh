#!/bin/zsh
account=$1
cd ~/.local/share/mail/$account && gmi push -q >/dev/null 2>&1
