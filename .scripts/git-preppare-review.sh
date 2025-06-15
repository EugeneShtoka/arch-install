#!/bin/zsh

feature_branch=$1

mkdir -p toReview && \
git diff --name-only main...$feature_branch | \
while read -r filepath; do
  cp "$filepath" "toReview/$(basename "$filepath").orig"
done