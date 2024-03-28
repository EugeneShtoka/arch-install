#!/bin/zsh

OLD_LINE_PATTERN=$1;
NEW_LINE=$2;
FILE=$3

NEW=$(echo "${NEW_LINE}" | sed 's/\//\\\//g')
sed -i.bak '/'"${OLD_LINE_PATTERN}"'/s/.*/'"${NEW}"'/' "${FILE}"
mv "${FILE}.bak" /tmp/
