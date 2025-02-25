#!/bin/zsh
# Usage: git-create-merge-request.sh "branch" "jira-id" "jira-url"

git stash  

git switch main;  
git pull;  
git checkout -b eugene/$2-$1;  
	
git stash apply  
	
git add .;  
git commit -m $1;
git push --set-upstream origin eugene/$2-$1
glab mr create -t $1 -d "[jira](https://work-url-$2)";

