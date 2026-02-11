#!/bin/zsh

alias torrent='setsid qbittorrent &>/dev/null'
alias music-notation='setsid /usr/bin/env XDG_SESSION_TYPE=x11 mscore &>/dev/null'

alias cs-pull=$SCRIPTS_PATH/custom-scripts-pull.sh
alias cs-push=$SCRIPTS_PATH/custom-scripts-push.sh

alias reader=$SCRIPTS_PATH/book-read.sh

alias play-list=$SCRIPTS_PATH/music-play-list.sh
alias play=$SCRIPTS_PATH/music-play.sh
alias stop=$SCRIPTS_PATH/music-stop.sh

alias pgd='setsid xdg-open "https://drive.google.com/drive/u/0/my-drive" &>/dev/null'
alias syncthing='setsid xdg-open "http://127.0.0.1:8384" &>/dev/null'

alias spnd='suspend'
alias stdn='shutdown now'

alias epub-download='c search -e epub -r 50'
alias book-download='libgen search -r 50'

source $SCRIPTS_PATH/projects-aliases.sh
source $SCRIPTS_PATH/games-aliases.sh

# To maintain this as last item - it should be last in the list
alias rename='setsid thunar --bulk-rename &>/dev/null'
