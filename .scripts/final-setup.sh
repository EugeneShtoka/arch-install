$SCRIPTS_PATH/config-launcher.sh

rclone config

$SCRIPTS_PATH/git-set-up.sh
$SCRIPTS_PATH/generate-ssh-key.sh $PERSONAL_EMAIL personal https://github.com/settings/ssh/new
gh auth login

$SCRIPTS_PATH/generate-ssh-key.sh $WORK_EMAIL work https://gitlab.com/-/profile/keys
glab auth login
read -p "Enter ssh key name for GitLab: " keyName
glab ssh-key add .ssh/id_ed25519_work.pub -t $keyName

git clone $OBSIDIAN_GIT_REPO $OBSIDIAN_PATH