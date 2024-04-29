#!/bin/zsh



=$1
if [ -z "$1" ]; then
    path=$(pwd)
    PROJECT_NAME="${path##*/}"
else
    PROJECT_NAME=$1
fi

gh repo create $PROJECT_NAME --public
git init
git add -A
git commit -m 'Initial commit'
git remote add origin git@github.com:EugeneShtoka/$PROJECT_NAME.git
git push -u -f origin main