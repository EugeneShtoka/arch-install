#!/bin/zsh

feature_branch=$1

rm -rf ~/toReview
mkdir -p ~/toReview

git diff --name-only main...$feature_branch | \
while read -r filepath; do
  cp "$filepath" "~/toReview/$(basename "$filepath").orig"
done


