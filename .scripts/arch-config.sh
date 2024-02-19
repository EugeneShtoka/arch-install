#!/bin/bash

cd ~

sudo ln -s $SERVICES_PATH/org.freedesktop.Notifications.service /usr/share/dbus-1/services/org.freedesktop.Notifications.service
systemctl --user enable start-up-routine
$SCRIPTS_PATH/rofi-theme-install.sh
$SCRIPTS_PATH/config-launcher.sh

rclone config

$SCRIPTS_PATH/git-set-up.sh
$SCRIPTS_PATH/ssh-key-generate.sh $PERSONAL_EMAIL personal
gh auth login
git remote set-url origin git@github.com:EugeneShtoka/arch-install.git
git clone $OBSIDIAN_GIT_REPO $OBSIDIAN_PATH

$SCRIPTS_PATH/ssh-key-generate.sh $WORK_EMAIL work
glab auth login
read -p "Enter ssh key name for GitLab: " keyName
glab ssh-key add .ssh/id_ed25519_work.pub -t $keyName 

gsettings set org.gnome.desktop.interface gtk-theme Pop

$SCRIPTS_PATH/bw-unlock.sh
bw get item 'SWAPP GCloud credentials' | jq '.notes | jq 'fromjson' >> swapp-v1-1564402864804.json
sudo mkdir /usr/share/credentials
sudo mv swapp-v1-1564402864804.json /usr/share/credentials/

bw get item 'SWAPP GCS credentials' | jq '.notes' | jq 'fromjson' >> swapp-v1-1564402864804-storage.json
sudo mv swapp-v1-1564402864804-storage.json /usr/share/credentials/

gcloud auth login
gcloud config set project swapp-v1-1564402864804
