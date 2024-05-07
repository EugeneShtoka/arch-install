#!/bin/zsh

if [ -z "$1" ]; then
    path=$(pwd)
    PROJECT_NAME="${path##*/}"
else
    PROJECT_NAME=$1
fi

/bin/gh repo create $PROJECT_NAME --public
/bin/git init
/bin/git add -A
/bin/git commit -m 'Initial commit'
/bin/git remote add origin git@github.com:EugeneShtoka/$PROJECT_NAME.git
/bin/git push -u -f origin main