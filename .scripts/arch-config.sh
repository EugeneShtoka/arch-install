#!/bin/zsh

cd ~

sudo ln -s $SERVICES_PATH/org.freedesktop.Notifications.service /usr/share/dbus-1/services/org.freedesktop.Notifications.service
systemctl --user enable start-up-routine.service
systemctl --user start pipewire-pulse
systemctl enable bluetooth.service

if [ "$IS_LAPTOP" -eq 1 ]; then
    $SCRIPTS_PATH/laptop-setup.sh
fi

RULE_FILE="/etc/udev/rules.d/20-pcspkr-beep.rules"
CONTENT="SUBSYSTEM==\"input\", ACTION==\"add\", ATTRS{name}==\"PC Speaker\", ENV{DEVNAME}!=\"\", GROUP=\"beep\", MODE=\"0620\""

echo -e "$CONTENT" | sudo tee "$RULE_FILE" >/dev/null

sudo udevadm control --reload

$SCRIPTS_PATH/rofi-theme-install.sh

echo config web browser
source $SCRIPTS_PATH/bw-unlock.sh
echo personal gmail
$SCRIPTS_PATH/bw-item.sh g.personal
echo github
$SCRIPTS_PATH/bw-item.sh g.github

$SCRIPTS_PATH/rclone-config.sh

$SCRIPTS_PATH/ssh-generate-key.sh $PERSONAL_EMAIL personal
gh auth login
git remote set-url origin git@github.com:EugeneShtoka/arch-install.git

mkdir .tmp

echo 'Setting Gemini secret key'
bw get item "gemini" | jq '.notes' | tr -d \" | secret-tool store --label="Gemini sercret key" provider gemini profile default key-pair secret

$SCRIPTS_PATH/atuin-install.sh

bw get item 'SWAPP GCloud credentials' | jq '.notes' | jq 'fromjson' >>swapp-v1-1564402864804.json
sudo mkdir /usr/share/credentials
sudo mv swapp-v1-1564402864804.json /usr/share/credentials/

bw get item 'SWAPP GCS credentials' | jq '.notes' | jq 'fromjson' >>swapp-v1-1564402864804-storage.json
sudo mv swapp-v1-1564402864804-storage.json /usr/share/credentials/

gcloud auth login
gcloud config set project swapp-v1-1564402864804

awsTerraCreds=$(bw get item 'aws.terraform' | jq)
echo "AWS config"
echo "AWS Access Key ID:" $(echo $awsTerraCreds | grep -A 1 '"secret access key"' | awk '{print $2}' | tail -1 | tr -d \",)
echo "AWS Secret Access Key:" $(echo $awsTerraCreds | grep -A 1 '"access key"' | awk '{print $2}' | tail -1 | tr -d \",)
aws configure

conda config --set changeps1 false
