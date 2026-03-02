#!/bin/zsh

git fetch origin
git reset --soft $(git merge-base HEAD origin/$GIT_DEFAULT_BRANCH)
git commit -m "squashed feature"
git push -f
