#!/bin/zsh

alias yayi=$SCRIPTS_PATH/auto-yay.sh

alias zrc='source $SCRIPTS_PATH/zsh-reload-config.sh'
alias bw-unlock='source $SCRIPTS_PATH/bw-unlock.sh'
alias bw-create='source $SCRIPTS_PATH/bw-create.sh'
alias bw-item='source $SCRIPTS_PATH/bw-item.sh'
alias bw-pass='source $SCRIPTS_PATH/bw-copy-pass.sh'
alias postal-code='source $SCRIPTS_PATH/postal-code-get.sh'

alias gsm='git stash && git switch main && git pull && git stash apply'
alias grf='git checkout main --'
alias gsp='git switch -'
alias gsb='git switch'
alias gpl='git pull'
alias ghr='git reset --hard HEAD^ && git pull'

alias gsq=$SCRIPTS_PATH/git-squash.sh
alias gpc=$SCRIPTS_PATH/git-push-commit.sh
alias gcpr=$SCRIPTS_PATH/git-create-pull-request.sh
alias gcmr=$SCRIPTS_PATH/git-create-merge-request.sh
alias git-alias-main='git symbolic-ref refs/heads/main refs/heads/$(git rev-parse --abbrev-ref HEAD)'

alias home='cd ~ && code . && clr'
alias figoro='cd $HOME/dev/figoro && code . && clr'
alias blog='cd $HOME/dev/blog && code . && clr'
alias aps='cd $WORK_REPOS_PATH/swapp-aps && code . && clr'
alias plugin='cd $WORK_REPOS_PATH/revit-plugin && code . && clr'
alias workflows='cd $WORK_REPOS_PATH/workflows && code . && clr'
alias backend='cd $WORK_REPOS_PATH/swappbackend && code . && clr'
alias algo='cd $WORK_REPOS_PATH/roomassignment && code . && clr'

alias ls='eza --icons -a'
alias ll='eza --icons -al'
alias clr='/usr/bin/clear'
alias copy='xclip -selection c'
alias paste='xclip -out -selection c'
alias yayr='sudo pacman -R'
alias psgrep='ps aux | grep -v grep | grep -i -e VSZ -e'
alias install=$SCRIPTS_PATH/app-search-and-install.sh
alias uninstall=$SCRIPTS_PATH/app-uninstall.sh
alias gmn=$SCRIPTS_PATH/gemini-call.sh
alias calc=$SCRIPTS_PATH/calculate.sh
alias timer='setsid $SCRIPTS_PATH/calculate.sh'

alias tsm='mop -profile ~/.config/mop/market.moprc'
alias tsp='mop -profile ~/.config/mop/portfolio.moprc'

alias mirophone-mute='pactl set-source-mute $(pactl get-default-source) 1'
alias mirophone-unmute='pactl set-source-mute $(pactl get-default-source) 0'
