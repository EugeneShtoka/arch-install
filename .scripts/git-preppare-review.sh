#!/bin/zsh

feature_branch=$(git branch --show-current)
echo "Feature branch: $feature_branch"

review_dir="$HOME/toReview"

echo "Cleaning and creating directory: $review_dir"
rm -rf "$review_dir"
mkdir -p "$review_dir"

git switch -

echo "Copying original files to $review_dir from" $(git branch --show-current)

git diff --name-only "development...$feature_branch" | while read -r filepath; do
	if [ -f "$filepath" ]; then
		dest_filename="orig_$(basename "$filepath")"
		echo "  -> Copying $filepath to $review_dir/$dest_filename"
		cp "$filepath" "$review_dir/$dest_filename"
	else
		echo "  -> Skipping $filepath (it may have been deleted)"
	fi
done

echo "Copy complete."

git switch -

echo "Copying changed files to $review_dir from" $(git branch --show-current)

git diff --name-only "development...$feature_branch" | while read -r filepath; do
	if [ -f "$filepath" ]; then
		dest_filename="$(basename "$filepath")"
		echo "  -> Copying $filepath to $review_dir/$dest_filename"
		cp "$filepath" "$review_dir/$dest_filename"
	else
		echo "  -> Skipping $filepath (it may have been deleted)"
	fi
done

echo "Script finished on branch: $(git branch --show-current)"
