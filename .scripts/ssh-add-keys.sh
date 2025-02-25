#!/bin/zsh

echo "`date` ssh-add-keys" >> $LOG_PATH
ssh-add ~/.ssh/id_ed25519_personal