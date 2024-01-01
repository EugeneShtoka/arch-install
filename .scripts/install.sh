
ZSH_AUTOSUGGESTION_PATH=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
rm -rf $ZSH_AUTOSUGGESTION_PATH
git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_AUTOSUGGESTION_PATH

ZSH_SYNTAX_HIGHLIGHTING_PATH=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
rm -rf $ZSH_SYNTAX_HIGHLIGHTING_PATH
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_SYNTAX_HIGHLIGHTING_PATH

$SCRIPTS_PATH/yay-install.sh

$SCRIPTS_PATH/auto-yay.sh google-chrome
$SCRIPTS_PATH/auto-yay.sh slack-desktop
$SCRIPTS_PATH/auto-yay.sh zoom
$SCRIPTS_PATH/auto-yay.sh bluemail
$SCRIPTS_PATH/auto-yay.sh obsidian
$SCRIPTS_PATH/auto-yay.sh glab-git
$SCRIPTS_PATH/auto-yay.sh github-cli
$SCRIPTS_PATH/auto-yay.sh qbittorrent-enhanced
$SCRIPTS_PATH/auto-yay.sh visual-studio-code-bin
$SCRIPTS_PATH/auto-yay.sh qemu-full
$SCRIPTS_PATH/auto-yay.sh docker-desktop
$SCRIPTS_PATH/auto-yay.sh npm
$SCRIPTS_PATH/auto-yay.sh rclone
$SCRIPTS_PATH/auto-yay.sh zsh-git-prompt-hs-git

rclone config

$SCRIPTS_PATH/git-set-up.sh
$SCRIPTS_PATH/generate-ssh-key.sh $PERSONAL_EMAIL personal https://github.com/settings/ssh/new
read -n 1 -s -r -p "Have you copied ssh key to github? Press Enter to continue..."
$SCRIPTS_PATH/git-set-up.sh $WORK_EMAIL work https://gitlab.com/-/profile/keys
read -n 1 -s -r -p "Have you copied ssh key to gitlab? Press Enter to continue..."

gh auth login
git clone $OBSIDIAN_GIT_REPO $OBSIDIAN_PATH
