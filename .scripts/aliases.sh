#!/bin/zsh

alias browser='setsid $BROWSER &>/dev/null'
alias mail='setsid mailspring --password-store="gnome-libsecret" &>/dev/null'
alias slack='setsid /usr/bin/slack -s &>/dev/null'
alias messenger='setsid beeper --no-sandbox --default-frame &>/dev/null'
alias zoom='setsid /usr/bin/zoom &>/dev/null'
alias postman='setsid /opt/postman/Postman &>/dev/null'
alias notes='setsid obsidian &>/dev/null'
alias torrent='setsid qbittorrent &>/dev/null'
alias file-manager='setsid thunar &>/dev/null'
alias keyboard-trainer='setsid tipp10 &>/dev/null'
alias music-notation='setsid /usr/bin/env XDG_SESSION_TYPE=x11 mscore &>/dev/null'

alias cs-pull=$SCRIPTS_PATH/custom-scripts-pull.sh
alias cs-push=$SCRIPTS_PATH/custom-scripts-push.sh
alias upgrade=$SCRIPTS_PATH/system-upgrade.sh
alias glb=$SCRIPTS_PATH/gitlab-open.sh
alias play=$SCRIPTS_PATH/music-play.sh
alias stop=$SCRIPTS_PATH/music-stop.sh
alias read=$SCRIPTS_PATH/book-read.sh

alias gemini='setsid $BROWSER "https://gemini.google.com/app" &>/dev/null'
alias ytb='setsid $BROWSER "https://www.youtube.com" &>/dev/null'
alias ghb='setsid $BROWSER "https://github.com" &>/dev/null'
alias gcp='setsid $BROWSER "https://console.cloud.google.com/welcome?pli=1&project=swapp-v1-1564402864804&authuser=1" &>/dev/null'
alias gcp-composer='setsid $BROWSER "https://console.cloud.google.com/composer/environments?referrer=search&authuser=1&project=swapp-v1-1564402864804" &>/dev/null'
alias gcp-airflow='setsid $BROWSER "https://15f236baf9994fd7a4d6ae3be218aaf8-dot-us-central1.composer.googleusercontent.com/home" &>/dev/null'
alias pgd='setsid $BROWSER "https://drive.google.com/drive/u/0/my-drive" &>/dev/null'
alias wgd='setsid $BROWSER "https://drive.google.com/drive/u/1/my-drive" &>/dev/null'
alias jira='setsid $BROWSER "https://swapp-ai.atlassian.net/jira/software/c/projects/SWP/boards/1?assignee=712020%3Aee767fac-fcf2-4a03-a591-ccc8a59a097b" &>/dev/null'
alias coralogix='setsid $BROWSER "https://swapp.app.coralogix.us/#/dashboard" &>/dev/null'

alias spnd='mirophone-unmute && systemctl suspend'
alias stdn='mirophone-unmute && shutdown now'

alias db-proxy='pkill cloud-sql-proxy &>/dev/null; setsid cloud-sql-proxy swapp-v1-1564402864804:us-central1:swapp-postgres-db -p 5433 -c /usr/share/credentials/swapp-v1-1564402864804.json &>/dev/null'

alias against-the-storm='setsid /mnt/Games/Against\ The\ Storm/start.sh &>/dev/null'
alias europa='setsid /mnt/Games/Europa/start.sh &>/dev/null'
alias victoria='setsid /mnt/Games/Victoria/binaries/victoria3 &>/dev/null'
alias rim-world='setsid /mnt/Games/RimWorld/start.sh &>/dev/null'

# To maintain this as last item - it should be last in the list
alias bulk-rename='setsid thunar --bulk-rename &>/dev/null'
