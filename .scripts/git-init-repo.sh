#!/bin/zsh

path=$(pwd)
folder="${path##*/}"

PROJECT_NAME=$1
if [[ ]]
gh repo create $PROJECT_NAME --public
git init
git add -A
git commit -m 'Initial commit'
git remote add origin git@github.com:EugeneShtoka/$PROJECT_NAME.git
git push -u -f origin main