#!/bin/zsh

alias yayi=$SCRIPTS_PATH/auto-yay.sh

alias zrc='source $SCRIPTS_PATH/zsh-reload-config.sh'
alias bw-unlock='source $SCRIPTS_PATH/bw-unlock.sh'
alias bw-create='source $SCRIPTS_PATH/bw-create.sh'
alias bw-item='source $SCRIPTS_PATH/bw-item.sh'
alias bw-pass='source $SCRIPTS_PATH/bw-copy-pass.sh'
alias postal-code='source $SCRIPTS_PATH/postal-code-get.sh'

alias gsm='git switch main'
alias grf='git checkout main --'
alias gsp='git switch -'
alias gsb='git switch'
alias gpl='git pull'
alias ghr='git reset --hard HEAD^ && git pull'
alias gsq=$SCRIPTS_PATH/git-squash.sh
alias gpc=$SCRIPTS_PATH/git-push-commit.sh
alias gcpr=$SCRIPTS_PATH/git-create-pull-request.sh
alias gcmr=$SCRIPTS_PATH/git-create-merge-request.sh

alias home='cd ~ && code . && clear'
alias gcalcli='cd $HOME/dev/gcalcli && code . && clear'
alias aps='cd $WORK_REPOS_PATH/swapp=aps && code . && clear'
alias plugin='cd $WORK_REPOS_PATH/revit-plugin && code . && clear'
alias workflows='cd $WORK_REPOS_PATH/workflows && code . && clear'
alias backend='cd $WORK_REPOS_PATH/swappbackend && code . && clear'
alias roomassignment='cd $WORK_REPOS_PATH/roomassignment && code . && clear'

alias ls='eza --icons -a'
alias ll='eza --icons -al'
alias copy='xclip -selection c'
alias paste='xclip -out -selection c'
alias yayr='sudo pacman -R'

alias mirophone-mute='pactl set-source-mute $(pactl get-default-source) 1'
alias mirophone-unmute='pactl set-source-mute $(pactl get-default-source) 0'
