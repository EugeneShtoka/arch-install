#!/bin/zsh

git fetch origin
default_branch=$(git symbolic-ref --short refs/heads/$GIT_DEFAULT_BRANCH)
base=$(git merge-base HEAD origin/$default_branch)

if [[ -n $1 ]]; then
  msg=$1
else
  msg=$(git log --reverse --format="%s" $base..HEAD)
fi

git reset --soft $base
git commit -m "$msg"
git push -f
