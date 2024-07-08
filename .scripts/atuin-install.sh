#!/bin/zsh

bash <(curl --proto '=https' --tlsv1.2 -sSf https://setup.atuin.sh)
exit
$SCRIPTS_PATH/zsh-reload-config.sh
bw-item atuin
atuin login
atuin import auto
atuin sync
