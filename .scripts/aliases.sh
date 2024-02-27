#!/bin/zsh

alias gmn='setsid vivaldi-snapshot "https://gemini.google.com/app" &>/dev/null'
alias ytb='setsid vivaldi-snapshot "https://www.youtube.com" &>/dev/null'
alias ghb='setsid vivaldi-snapshot "https://github.com" &>/dev/null'
alias glb='setsid vivaldi-snapshot "https://gitlab.com" &>/dev/null'
alias gcp='setsid vivaldi-snapshot "https://console.cloud.google.com/welcome?pli=1&project=swapp-v1-1564402864804&authuser=1" &>/dev/null'
alias gdp='setsid vivaldi-snapshot "https://drive.google.com/drive/u/0/my-drive" &>/dev/null'
alias gdw='setsid vivaldi-snapshot "https://drive.google.com/drive/u/1/my-drive" &>/dev/null'
alias jira='setsid vivaldi-snapshot "https://swapp-ai.atlassian.net/jira/software/c/projects/SWP/boards/1?assignee=712020%3Aee767fac-fcf2-4a03-a591-ccc8a59a097b" &>/dev/null'

alias torrent='setsid qbittorrent &>/dev/null'
alias obsidian='setsid obsidian &>/dev/null'
alias db-tool='setsid $SCRIPTS_PATH/dbeaver-start.sh &>/dev/null'
alias file-manager='setsid thunar &>/dev/null'
alias bulk-rename='setsid thunar --bulk-rename &>/dev/null'
alias docker-start='setsid /opt/docker-desktop/bin/com.docker.url-handler &>/dev/null'
alias mail='setsid mailspring --password-store="gnome-libsecret" &>/dev/null'
alias messenger='setsid beeper --no-sandbox &>/dev/null'
alias browser='setsid vivaldi-snapshot &>/dev/null'
alias slack='setsid /usr/bin/slack -s &>/dev/null'
alias postman='setsid /opt/postman/Postman --bulk-rename &>/dev/null'
alias zoom='setsid zoom &>/dev/null'

alias cs-pull=$SCRIPTS_PATH/custom-scripts-pull.sh
alias cs-push=$SCRIPTS_PATH/custom-scripts-push.sh
alias daily=$SCRIPTS_PATH/zoom-join-daily.sh
alias monitors-init=$SCRIPTS_PATH/monitors-init.sh
alias play=$SCRIPTS_PATH/music-play.sh
alias stop=$SCRIPTS_PATH/music-stop.sh
alias zrc=$SCRIPTS_PATH/zsh-reload-config.sh

alias spnd='systemctl suspend'



