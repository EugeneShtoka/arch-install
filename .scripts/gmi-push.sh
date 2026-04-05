#!/bin/zsh
(for account_dir in ~/.local/share/mail/*/; do
    (cd $account_dir && gmi push -fq >/dev/null 2>&1) &
done
wait
notmuch new >/dev/null 2>&1) &
