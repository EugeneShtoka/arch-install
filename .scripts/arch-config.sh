#!/bin/zsh

cd ~

sudo ln -s $SERVICES_PATH/org.freedesktop.Notifications.service /usr/share/dbus-1/services/org.freedesktop.Notifications.service
systemctl --user enable start-up-routine.service
systemctl enable bluetooth.service
$SCRIPTS_PATH/rofi-theme-install.sh

echo config web browser
source $SCRIPTS_PATH/bw-unlock.sh
echo work gmail
$SCRIPTS_PATH/bw-item.sh g.personal
echo personal gmail
$SCRIPTS_PATH/bw-item.sh g.work
echo github
$SCRIPTS_PATH/bw-item.sh g.github

$SCRIPTS_PATH/rclone-config.sh

$SCRIPTS_PATH/ssh-generate-key.sh $PERSONAL_EMAIL personal
gh auth login
git remote set-url origin git@github.com:EugeneShtoka/arch-install.git

$SCRIPTS_PATH/ssh-generate-key.sh $WORK_EMAIL work
glab auth login
read -p "Enter ssh key name for GitLab: (PC/Laptop)" keyName
glab ssh-key add .ssh/id_ed25519_work.pub -t $keyName 

mkdir .tmp

echo 'Set Gemini secret key. Paste following value as Password'
bw get item "gemini" | jq '.notes' | tr -d \"
secret-tool store --label="Gemini sercret key" provider gemini profile default key-pair secret

$SCRIPTS_PATH/atuin-install.sh

bw get item 'SWAPP GCloud credentials' | jq '.notes' | jq 'fromjson' >> swapp-v1-1564402864804.json
sudo mkdir /usr/share/credentials
sudo mv swapp-v1-1564402864804.json /usr/share/credentials/

bw get item 'SWAPP GCS credentials' | jq '.notes' | jq 'fromjson' >> swapp-v1-1564402864804-storage.json
sudo mv swapp-v1-1564402864804-storage.json /usr/share/credentials/

gcloud auth login
gcloud config set project swapp-v1-1564402864804

awsTerraCreds=$(bw get item 'aws.terraform' | jq)
echo "AWS config"
echo "AWS Access Key ID:" $(echo $awsTerraCreds | grep -A 1 '"secret access key"' | awk '{print $2}' | tail -1 | tr -d \",)
echo "AWS Secret Access Key:" $(echo $awsTerraCreds | grep -A 1 '"access key"' | awk '{print $2}' | tail -1 | tr -d \",)
aws configure