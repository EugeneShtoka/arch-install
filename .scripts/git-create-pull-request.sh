#!/bin/zsh

title=$1
category=$2
if [[ -n $category ]]; then
    category=$GIT_DEFAULT_CATEGORY
fi
branchName=$category/${title// /-}

git stash

git switch $GIT_WORK_BRANCH
git pull
git checkout -b $branchName

git stash apply

git add -A
git commit -m "$title"
gh pr create -B main --fill