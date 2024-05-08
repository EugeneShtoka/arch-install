#!/bin/zsh

title=$1
category=$2
if [[ -n $category ]]; then
    category=eugene
fi
branchName=$category/${title// /-}

git stash

git switch main;
git pull;
git checkout -b $branchName;

git stash apply

git add .;
git commit -m "$title";
gh pr create -B main --fill;