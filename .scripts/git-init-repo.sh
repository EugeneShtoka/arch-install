#!/bin/zsh

if [ -z "$1" ]; then
    fullPath=$(pwd)
    PROJECT_NAME="${fullPath##*/}"
else
    PROJECT_NAME=$1
fi

gh repo create "$PROJECT_NAME" --public
git init
git add -A
git commit -m 'Initial commit'
git remote add origin git@github.com:EugeneShtoka/"$PROJECT_NAME".git
sleep 2
git push -u -f origin main