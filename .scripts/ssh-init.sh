#!/bin/zsh

check-ssh-agent() {
    [ -S "$SSH_AUTH_SOCK" ] && { ssh-add -l >& /dev/null || [ $? -ne 2 ]; }
}
check-ssh-agent || export SSH_AUTH_SOCK=~/.tmp/ssh-agent.sock
check-ssh-agent || eval "$(ssh-agent -s -a ~/.tmp/ssh-agent.sock)" > /dev/null

$SCRIPTS_PATH/ssh-add-keys.sh
notify-send "SSH_INIT" "<span font='15px'>INITIALIZING SSH $SSH_AUTH_SOCK $SCRIPTS_PATH</span>" --icon " " -r 101017