#!/bin/bash

echo "`date` ssh-add-keys ${SCRIPTS_PATH}" >> $LOG_PATH
ssh-add ~/.ssh/id_ed25519_personal
ssh-add ~/.ssh/id_ed25519_work