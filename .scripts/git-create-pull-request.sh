#!/bin/zsh

git stash

git switch main;
git pull;
git checkout -b "eugene/$1";

git stash apply

git add .;
git commit -m "$1";
gh pr create --fill;