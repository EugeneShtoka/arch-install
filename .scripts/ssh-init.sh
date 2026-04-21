#!/bin/zsh

check-ssh-agent() {
    [ -S "$SSH_AUTH_SOCK" ] || return 1
    ssh-add -l &>/dev/null
    [ $? -ne 2 ]
}
mkdir -p ~/.tmp
export SSH_AUTH_SOCK=~/.tmp/ssh-agent.sock
if ! check-ssh-agent; then
    rm -f ~/.tmp/ssh-agent.sock
    eval "$(ssh-agent -s -a ~/.tmp/ssh-agent.sock)" > /dev/null
fi

$SCRIPTS_PATH/ssh-add-keys.sh