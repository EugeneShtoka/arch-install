#!/bin/zsh

if [ -z "$1" ]; then
    fullPath=$(pwd)
    PROJECT_NAME="${fullPath##*/}"
else
    PROJECT_NAME=$1
fi

/bin/gh repo create $PROJECT_NAME --public
/bin/git init
/bin/git add -A
/bin/git commit -m 'Initial commit'
/bin/git remote add origin git@github.com:EugeneShtoka/$PROJECT_NAME.git
sleep 2
/bin/git push -u -f origin main