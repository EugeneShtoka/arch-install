#!/bin/zsh

alias yayi=$SCRIPTS_PATH/auto-yay.sh

alias zrc='source $SCRIPTS_PATH/zsh-reload-config.sh'
alias bw-unlock='source $SCRIPTS_PATH/bw-unlock.sh'
alias bw-create='source $SCRIPTS_PATH/bw-create.sh'
alias bw-item='source $SCRIPTS_PATH/bw-item.sh'
alias bw-pass='source $SCRIPTS_PATH/bw-copy-pass.sh'
alias postal-code='source $SCRIPTS_PATH/postal-code-get.sh'

alias gsd='git stash && git switch $GIT_DEFAULT_BRANCH && git pull && clear'
alias grf='git checkout $GIT_DEFAULT_BRANCH --'
alias gsp='git switch -'
alias gsb='git fetch && git switch'
alias gpl='git pull'
alias ghr='git reset --hard HEAD^ && git pull'

alias gsq=$SCRIPTS_PATH/git-squash.sh
alias gpc=$SCRIPTS_PATH/git-push-commit.sh
alias gcpr=$SCRIPTS_PATH/git-create-pull-request.sh
alias gor=$SCRIPTS_PATH/git-open-repo.sh
alias git-alias-default-branch='git symbolic-ref refs/heads/$GIT_DEFAULT_BRANCH refs/heads/$(git rev-parse --abbrev-ref HEAD)'

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
alias wifi=$SCRIPTS_PATH/wifi-connect.sh

alias mail=$SCRIPTS_PATH/email-start.sh
alias file-manager=$SCRIPTS_PATH/file-manager-start.sh

alias tsm='mop -profile ~/.config/mop/market.moprc'
alias tsp='mop -profile ~/.config/mop/portfolio.moprc'

alias microphone-mute='pactl set-source-mute $(pactl get-default-source) 1'
alias microphone-unmute='pactl set-source-mute $(pactl get-default-source) 0'

# TipMaster
alias db-tunnel-start='ssh -fN -i ~/.ssh/tm-bastion -L 5433:tipmaster-prd.clmokqmsk1un.us-east-2.rds.amazonaws.com:5432 ec2-user@3.130.146.14'
alias db-tunnel-stop='pkill -f "ssh.*3.130.146.14"'
alias ks="aws sso login --profile dev && kubie ctx dev-cluster && kubectl get nodes"
