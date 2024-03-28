#!/bin/zsh

yes | LANG=C yay --provides=false --answerdiff None --answerclean None --mflags "--noconfirm" -S $1
