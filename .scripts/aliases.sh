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
alias pgd='setsid $BROWSER "https://drive.google.com/drive/u/0/my-drive" &>/dev/null'
alias syncthing='setsid $BROWSER "http://127.0.0.1:8384" &>/dev/null'

alias spnd='mirophone-unmute && systemctl suspend'
alias stdn='mirophone-unmute && shutdown now'

alias epub-download='c search -e epub -r 50'
alias book-download='libgen search -r 50'

alias against-the-storm='setsid ~/Games/AgainstTheStorm/start.sh &>/dev/null'
alias europa='setsid ~/Games/Europa/start.sh &>/dev/null'
alias victoria='setsid ~/Games/Victoria/binaries/victoria3 &>/dev/null'
alias rim-world='setsid ~/Games/RimWorld/start.sh &>/dev/null'

# To maintain this as last item - it should be last in the list
alias rename='setsid thunar --bulk-rename &>/dev/null'
