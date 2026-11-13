#!/bin/zsh
# Prints "<alias>\t<display name>" per game; the name is the alias line's trailing
# comment, or the alias itself when there is none.

while IFS= read -r line || [[ -n $line ]]; do
  if [[ $line =~ "^alias ([a-z,-]+)=.*'[[:space:]]*#[[:space:]]*(.+)$" ]]; then
    print -r -- "$match[1]"$'\t'"$match[2]"
  elif [[ $line =~ '^alias ([a-z,-]+)=' ]]; then
    print -r -- "$match[1]"$'\t'"$match[1]"
  fi
done < $SCRIPTS_PATH/aliases-games.sh
