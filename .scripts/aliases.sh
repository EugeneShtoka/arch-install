#!/bin/zsh

alias gmn='setsid vivaldi-snapshot "https://gemini.google.com/app" &>/dev/null'
alias ytb='setsid vivaldi-snapshot "https://www.youtube.com" &>/dev/null'
alias ghb='setsid vivaldi-snapshot "https://github.com" &>/dev/null'
alias glb='setsid vivaldi-snapshot "https://gitlab.com" &>/dev/null'
alias gcp='setsid vivaldi-snapshot "https://console.cloud.google.com/welcome?pli=1&project=swapp-v1-1564402864804&authuser=1" &>/dev/null'
alias gdp='setsid vivaldi-snapshot "https://drive.google.com/drive/u/0/my-drive" &>/dev/null'
alias gdw='setsid vivaldi-snapshot "https://drive.google.com/drive/u/1/my-drive" &>/dev/null'
alias gdw='setsid vivaldi-snapshot "https://swapp-ai.atlassian.net/jira/software/c/projects/SWP/boards/1?assignee=712020%3Aee767fac-fcf2-4a03-a591-ccc8a59a097b" &>/dev/null'

alias torrent='setsid qbittorrent &>/dev/null'
alias obsidian='setsid obsidian &>/dev/null'
alias db-tool='setsid /usr/local/bin/start-dbeaver.sh &>/dev/null'
alias bulk-rename='setsid thunar --bulk-rename &>/dev/null'

alias cs-pull=$SCRIPTS_PATH/custom-scripts-pull.sh
alias cs-push=$SCRIPTS_PATH/custom-scripts-push.sh
alias daily=$SCRIPTS_PATH/zoom-join-daily.sh
alias monitors-init=$SCRIPTS_PATH/monitors-init.sh
alias play=$SCRIPTS_PATH/music-play.sh
alias stop=$SCRIPTS_PATH/music-stop.sh
alias yayi=$SCRIPTS_PATH/auto-yay.sh
alias zrc=$SCRIPTS_PATH/zsh-reload-config.sh

alias bw-unlock='source $SCRIPTS_PATH/bw-unlock.sh'
alias bw-create='source $SCRIPTS_PATH/bw-create.sh'
alias bw-item='source $SCRIPTS_PATH/bw-item.sh'
alias bw-pass='source $SCRIPTS_PATH/bw-unlock.sh && $SCRIPTS_PATH/bw-pass.sh'
alias postal-code='source $SCRIPTS_PATH/postal-code-get.sh'

alias gsm='git switch main'
alias grf='git checkout main --'
alias gsp='git switch -'
alias gpc=$SCRIPTS_PATH/git-push-commit.sh
alias gcpr=$SCRIPTS_PATH/git-create-pull-request.sh
alias gcmr=$SCRIPTS_PATH/git-create-merge-request.sh

alias ls='eza --icons -a'
alias ll='eza --icons -al'
alias copy='xclip -selection c'
alias paste='xclip -out -selection c'
alias yayr='sudo pacman -R'
alias spnd='systemctl suspend'
alias stdn='shutdown now'