#!/bin/zsh

alias torrent='setsid qbittorrent &>/dev/null'
alias keyboard-trainer='setsid tipp10 &>/dev/null'
alias music-notation='setsid /usr/bin/env XDG_SESSION_TYPE=x11 mscore &>/dev/null'

alias cs-pull=$SCRIPTS_PATH/custom-scripts-pull.sh
alias cs-push=$SCRIPTS_PATH/custom-scripts-push.sh

alias reader='"$SCRIPTS_PATH/book-read.sh"'

alias play-list='"$SCRIPTS_PATH/music-play-list.sh"'
alias play='"$SCRIPTS_PATH/music-play.sh"'
alias stop='"$SCRIPTS_PATH/music-stop.sh"'

alias pgd='setsid xdg-open "https://drive.google.com/drive/u/0/my-drive" &>/dev/null'
alias syncthing='setsid xdg-open "http://127.0.0.1:8384" &>/dev/null'

alias spnd='suspend'
alias stdn='shutdown now'

alias epub-download='c search -e epub -r 50'
alias book-download='libgen search -r 50'

alias home='cd ~ && code . && clr'
alias figoro='cd $HOME/dev/figoro && code . && clr'
alias blog='cd $HOME/dev/blog && code . && clr'
alias backend='cd ~/dev/work/exbetz-be-api && code . && clr'

alias against-the-storm='setsid ~/Games/AgainstTheStorm/start.sh &>/dev/null'
alias europa='setsid ~/Games/Europa/start.sh &>/dev/null'
alias victoria='setsid ~/Games/Victoria\ 3/start &>/dev/null'
alias rim-world='setsid ~/Games/RimWorld/start.sh &>/dev/null'
alias bar='setsid ~/Games/Beyond\ All\ Reason/Beyond-All-Reason-1.2988.0.AppImage &>/dev/null'

# To maintain this as last item - it should be last in the list
alias rename='setsid thunar --bulk-rename &>/dev/null'
