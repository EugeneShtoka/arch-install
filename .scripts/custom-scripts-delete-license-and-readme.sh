#!/bin/zsh

cd $HOME
rm LICENSE
rm README.md
git update-index --assume-unchanged README.md
git update-index --assume-unchanged LICENSE