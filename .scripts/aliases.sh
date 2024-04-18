#!/bin/zsh

alias browser='setsid vivaldi-snapshot &>/dev/null'
alias mail='setsid mailspring --password-store="gnome-libsecret" &>/dev/null'
alias slack='setsid /usr/bin/slack -s &>/dev/null'
alias messenger='setsid beeper --no-sandbox &>/dev/null'
alias zoom='setsid /usr/bin/zoom &>/dev/null'
alias docker-start='setsid /opt/docker-desktop/bin/docker-desktop &>/dev/null'
alias postman='setsid /opt/postman/Postman &>/dev/null'
alias notes='setsid obsidian &>/dev/null'
alias torrent='setsid qbittorrent &>/dev/null'
alias file-manager='setsid thunar &>/dev/null'
alias bulk-rename='setsid thunar --bulk-rename &>/dev/null'
alias keyboard-trainer='setsid tipp10 &>/dev/null'
alias reader='setsid koodo-reader &>/dev/null'

alias cs-pull=$SCRIPTS_PATH/custom-scripts-pull.sh
alias cs-push=$SCRIPTS_PATH/custom-scripts-push.sh
alias upgrade=$SCRIPTS_PATH/apps-install.sh
alias daily=$SCRIPTS_PATH/zoom-join-daily.sh
alias glb=$SCRIPTS_PATH/gitlab-open.sh
alias play=$SCRIPTS_PATH/music-play.sh
alias stop=$SCRIPTS_PATH/music-stop.sh

alias gmn='setsid vivaldi-snapshot "https://gemini.google.com/app" &>/dev/null'
alias ytb='setsid vivaldi-snapshot "https://www.youtube.com" &>/dev/null'
alias ghb='setsid vivaldi-snapshot "https://github.com" &>/dev/null'
alias gcp='setsid vivaldi-snapshot "https://console.cloud.google.com/welcome?pli=1&project=swapp-v1-1564402864804&authuser=1" &>/dev/null'
alias gcp-composer='setsid vivaldi-snapshot "https://console.cloud.google.com/composer/environments?referrer=search&authuser=1&project=swapp-v1-1564402864804" &>/dev/null'
alias gcp-airflow='setsid vivaldi-snapshot "https://15f236baf9994fd7a4d6ae3be218aaf8-dot-us-central1.composer.googleusercontent.com/home" &>/dev/null'
alias pgd='setsid vivaldi-snapshot "https://drive.google.com/drive/u/0/my-drive" &>/dev/null'
alias wgd='setsid vivaldi-snapshot "https://drive.google.com/drive/u/1/my-drive" &>/dev/null'
alias jira='setsid vivaldi-snapshot "https://swapp-ai.atlassian.net/jira/software/c/projects/SWP/boards/1?assignee=712020%3Aee767fac-fcf2-4a03-a591-ccc8a59a097b" &>/dev/null'
alias coralogix='setsid vivaldi-snapshot "https://swapp.app.coralogix.us/#/dashboard" &>/dev/null'

alias spnd='mirophone-unmute && systemctl suspend'
alias stdn='mirophone-unmute && shutdown now'

alias db-proxy='pkill cloud-sql-proxy &>/dev/null; setsid cloud-sql-proxy swapp-v1-1564402864804:us-central1:swapp-postgres-db -p 5433 -c /usr/share/credentials/swapp-v1-1564402864804.json &>/dev/null'

alias against-the-storm='setsid /mnt/Games/Against\ The\ Storm/start.sh &>/dev/null'
alias europa='setsid /mnt/Games/Europa/start.sh &>/dev/null'
alias victoria='setsid /mnt/Games/Victoria/binaries/victoria3 &>/dev/null'
alias rim-world='setsid /mnt/Games/RimWorld/start.sh &>/dev/null'


