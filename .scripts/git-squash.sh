#!/bin/zsh

git fetch origin
base=$(git merge-base HEAD origin/$(git default_branch))

if [[ -n $1 ]]; then
  msg=$1
else
  msg=$(git log --reverse --format="%s" $base..HEAD)
fi

git reset --soft $base
git commit -m "$msg"
git push -f
