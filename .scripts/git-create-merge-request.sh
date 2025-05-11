#!/bin/zsh
# Usage: git-create-merge-request.sh "branch" "jira-id" "jira-url"

title=$1
jira_ticket=$2
category=$3
if [[ -n $category ]]; then
    category=$GIT_DEFAULT_CATEGORY
fi
branchName=$category/$jira_ticket-${title// /-}

git stash  

git switch $GIT_WORK_BRANCH;  
git pull;  
git checkout -b $branchName;  
	
git stash apply  
	
git add .;  
git commit -m $title;
git push --set-upstream origin $branchName
glab mr create -t $title -d "[jira](https://work-url-$jira_ticket)";

