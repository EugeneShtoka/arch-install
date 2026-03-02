#!/bin/zsh

git fetch origin
git reset --soft $(git merge-base HEAD origin/$defaultBranch)
git commit -m "squashed feature"
git push -f
branchFullName=$(git branch --show-current);  
git switch main;  
git pull;  
git checkout "$branchFullName";  
git pull;  
git reset "$(git merge-base main "${branchFullName}")";  
git add .;  
git commit -m "${branchFullName}-squash";  
git push -f;
