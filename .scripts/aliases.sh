#!/bin/zsh

alias torrent='setsid qbittorrent &>/dev/null'
alias file-manager='setsid thunar &>/dev/null'
alias keyboard-trainer='setsid tipp10 &>/dev/null'
alias music-notation='setsid /usr/bin/env XDG_SESSION_TYPE=x11 mscore &>/dev/null'

alias cs-pull=$SCRIPTS_PATH/custom-scripts-pull.sh
alias cs-push=$SCRIPTS_PATH/custom-scripts-push.sh
alias mail=$SCRIPTS_PATH/email-start.sh
alias glb=$SCRIPTS_PATH/gitlab-open.sh
alias play=$SCRIPTS_PATH/music-play.sh
alias stop=$SCRIPTS_PATH/music-stop.sh
alias reader=$SCRIPTS_PATH/book-read.sh

alias gemini='setsid $BROWSER "https://gemini.google.com/app" &>/dev/null'
alias ytb='setsid $BROWSER "https://www.youtube.com" &>/dev/null'
alias ghb='setsid $BROWSER "https://github.com" &>/dev/null'
alias gcp='setsid $BROWSER "https://console.cloud.google.com/welcome?pli=1&project=swapp-v1-1564402864804&authuser=1" &>/dev/null'
alias gcp-composer='setsid $BROWSER "https://console.cloud.google.com/composer/environments?referrer=search&authuser=1&project=swapp-v1-1564402864804" &>/dev/null'
alias gcp-airflow='setsid $BROWSER "https://15f236baf9994fd7a4d6ae3be218aaf8-dot-us-central1.composer.googleusercontent.com/home" &>/dev/null'
alias pgd='setsid $BROWSER "https://drive.google.com/drive/u/0/my-drive" &>/dev/null'
alias wgd='setsid $BROWSER "https://drive.google.com/drive/u/1/shared-drive" &>/dev/null'
alias jira='setsid $BROWSER "https://swapp-ai.atlassian.net/jira/software/c/projects/SWP/boards/1?assignee=712020%3Aee767fac-fcf2-4a03-a591-ccc8a59a097b" &>/dev/null'
alias syncthing='setsid $BROWSER "http://127.0.0.1:8384" &>/dev/null'

alias spnd='mirophone-unmute && systemctl suspend'
alias stdn='mirophone-unmute && shutdown now'

alias epub-download='c search -e epub -r 50'
alias book-download='libgen search -r 50'

alias db-proxy='pkill cloud-sql-proxy &>/dev/null; setsid cloud-sql-proxy swapp-v1-1564402864804:us-central1:swapp-postgres-db -p 5433 -c /usr/share/credentials/swapp-v1-1564402864804.json &>/dev/null'

alias against-the-storm='setsid /mnt/Games/Against\ The\ Storm/start.sh &>/dev/null'
alias europa='setsid /mnt/Games/Europa/start.sh &>/dev/null'
alias victoria='setsid /mnt/Games/Victoria/binaries/victoria3 &>/dev/null'
alias rim-world='setsid /mnt/Games/RimWorld/start.sh &>/dev/null'

# To maintain this as last item - it should be last in the list
alias rename='setsid thunar --bulk-rename &>/dev/null'
