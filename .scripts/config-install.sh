#!/bin/bash

cd ~

$SCRIPTS_PATH/rofi-theme-install.sh
$SCRIPTS_PATH/config-launcher.sh

rclone config

$SCRIPTS_PATH/git-set-up.sh
$SCRIPTS_PATH/generate-ssh-key.sh $PERSONAL_EMAIL personal
gh auth login
git remote set-url origin git@github.com:EugeneShtoka/arch-install.git
git clone $OBSIDIAN_GIT_REPO $OBSIDIAN_PATH

$SCRIPTS_PATH/generate-ssh-key.sh $WORK_EMAIL work
glab auth login
read -p "Enter ssh key name for GitLab: " keyName
glab ssh-key add .ssh/id_ed25519_work.pub -t $keyName 