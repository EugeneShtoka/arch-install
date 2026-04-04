#!/bin/zsh
mail_dir=~/.local/share/mail/e.shtoka@gmail.com/mail
moved=0
for f in $mail_dir/new/*(N); do
    mv "$f" $mail_dir/cur/"${f:t}:2,"
    moved=1
done
(( moved )) && notmuch new 2>/dev/null
(cd ~/.local/share/mail/e.shtoka@gmail.com && gmi push -q >/dev/null 2>&1) &!
