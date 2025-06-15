#!/bin/zsh

feature_branch=$(git branch --show-current)
echo "Feature branch: $feature_branch"

rm -rf ~/toReview
mkdir -p ~/toReview

git diff --name-only main...$feature_branch | \
while read -r filepath; do
  echo "File: $filepath"
  cp "$filepath" "~/toReview/$(basename "$filepath").orig"
done

gsp

git diff --name-only main...$feature_branch | \
while read -r filepath; do
  cp "$filepath" "~/toReview/$(basename "$filepath").orig"
done

gsp
