#!/bin/zsh

branchFullName=$(git branch --show-current);  
git switch main;  
git pull;  
git checkout "$branchFullName";  
git pull;  
git reset "$(git merge-base main "${branchFullName}")";  
git add .;  
git commit -m "${branchFullName}-squash";  
git push -f;