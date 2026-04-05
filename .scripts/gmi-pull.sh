#!/bin/zsh
for account_dir in ~/.local/share/mail/*/; do
    mail_dir=${account_dir}mail
    (cd $account_dir && gmi pull -q >/dev/null 2>&1)
    for f in $mail_dir/new/*(N); do
        mv "$f" $mail_dir/cur/"${f:t}:2,"
    done
done
notmuch new 2>/dev/null
