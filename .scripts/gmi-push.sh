#!/bin/zsh
for account_dir in ~/.local/share/mail/*/; do
    (cd $account_dir && gmi push -q >/dev/null 2>&1) &
done
wait
