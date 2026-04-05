#!/bin/zsh
account=$1
mail_dir=~/.local/share/mail/$account/mail
cd ~/.local/share/mail/$account && gmi pull -q >/dev/null 2>&1
for f in $mail_dir/new/*(N); do
    mv "$f" $mail_dir/cur/"${f:t}:2,"
done
notmuch new 2>/dev/null
~/.scripts/gmi-notify.sh
