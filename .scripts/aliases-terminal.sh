#!/bin/zsh

alias yayi=$SCRIPTS_PATH/auto-yay.sh

alias zrc='source $SCRIPTS_PATH/zsh-reload-config.sh'
alias bw-unlock='source $SCRIPTS_PATH/bw-unlock.sh'
alias bw-create='source $SCRIPTS_PATH/bw-create.sh'
alias bw-item='source $SCRIPTS_PATH/bw-item.sh'
alias bw-pass='source $SCRIPTS_PATH/bw-copy-pass.sh'
alias postal-code='source $SCRIPTS_PATH/postal-code-get.sh'

alias gsd='git stash && git switch $GIT_WORK_BRANCH && git pull && git stash apply'
alias grf='git checkout $GIT_WORK_BRANCH --'
alias gsp='git switch -'
alias gsb='git fetch && git switch'
alias gpl='git pull'
alias ghr='git reset --hard HEAD^ && git pull'

alias gsq=$SCRIPTS_PATH/git-squash.sh
alias gpc=$SCRIPTS_PATH/git-push-commit.sh
alias gcpr=$SCRIPTS_PATH/git-create-pull-request.sh
alias git-alias-work-branch='git symbolic-ref refs/heads/$GIT_WORK_BRANCH refs/heads/$(git rev-parse --abbrev-ref HEAD)'

alias ls='eza --icons -a'
alias ll='eza --icons -al'
alias clr='/usr/bin/clear'
alias psgrep='ps aux | grep -v grep | grep -i -e VSZ -e'
alias install=$SCRIPTS_PATH/app-search-and-install.sh
alias uninstall=$SCRIPTS_PATH/app-uninstall.sh
alias gmn=$SCRIPTS_PATH/gemini-call.sh
alias calc=$SCRIPTS_PATH/calculate.sh
alias timer="setsid $SCRIPTS_PATH/timer.sh"
alias upgrade=$SCRIPTS_PATH/system-upgrade.sh

alias tsm='mop -profile ~/.config/mop/market.moprc'
alias tsp='mop -profile ~/.config/mop/portfolio.moprc'

alias mirophone-mute='pactl set-source-mute $(pactl get-default-source) 1'
alias mirophone-unmute='pactl set-source-mute $(pactl get-default-source) 0'
