#!/bin/zsh

alias yayi='$SCRIPTS_PATH/auto-yay.sh'

alias bw-unlock='source $SCRIPTS_PATH/bw-unlock.sh'
alias bw-create='source $SCRIPTS_PATH/bw-create.sh'
alias bw-item='source $SCRIPTS_PATH/bw-item.sh'
alias bw-pass='source $SCRIPTS_PATH/bw-unlock.sh && $SCRIPTS_PATH/bw-pass.sh'
alias postal-code='source $SCRIPTS_PATH/postal-code-get.sh'

alias gsm='git switch main'
alias grf='git checkout main --'
alias gsp='git switch -'
alias gpl='git switch -'
alias ghr='git reset --hard HEAD^ && git pull'
alias gsq=$SCRIPTS_PATH/git-squash.sh
alias gpc=$SCRIPTS_PATH/git-push-commit.sh
alias gcpr=$SCRIPTS_PATH/git-create-pull-request.sh
alias gcmr=$SCRIPTS_PATH/git-create-merge-request.sh

alias home='$SCRIPTS_PATH/code-open-repo.sh .'
alias backend='$SCRIPTS_PATH/code-open-repo.sh backend'
alias roomasignment='$SCRIPTS_PATH/code-open-repo.sh roomasignment'

alias ls='eza --icons -a'
alias ll='eza --icons -al'
alias copy='xclip -selection c'
alias paste='xclip -out -selection c'
alias yayr='sudo pacman -R'

alias mirophone-mute='pactl set-source-mute $(pactl get-default-source) 1'
alias mirophone-unmute='pactl set-source-mute $(pactl get-default-source) 0'
