#!/bin/zsh

APPS_PATH=/usr/share/applications
HIDDEN=$APPS_PATH-hidden
mkdir $HIDDEN

sudo $SCRIPTS_PATH/replace-line.sh "theme='style-1'" "theme='style-2'" "$HOME/.config/rofi/launchers/type-2/launcher.sh"      

sudo $SCRIPTS_PATH/replace-line.sh "Icon=" "Icon=$ICON_PATH/terminal.png" "$APPS_PATH/kitty.desktop"
sudo $SCRIPTS_PATH/replace-line.sh "Name=" "Name=Terminal" "$APPS_PATH/kitty.desktop"
sudo $SCRIPTS_PATH/replace-line.sh "Icon=" "Icon=$ICON_PATH/file-manager.png" "$APPS_PATH/thunar.desktop"
sudo $SCRIPTS_PATH/replace-line.sh "Name=" "Name=File Manager" "$APPS_PATH/thunar.desktop"
sudo $SCRIPTS_PATH/replace-line.sh "Name=" "Name=VS Code" "$APPS_PATH/code.desktop"
sudo $SCRIPTS_PATH/replace-line.sh "Name=" "Name=DBeaver" "$APPS_PATH/io.dbeaver.DBeaver.desktop"
sudo $SCRIPTS_PATH/replace-line.sh "Name=" "Name=DBeaver" "$APPS_PATH/io.dbeaver.DBeaver.desktop"
sudo $SCRIPTS_PATH/replace-line.sh "Exec=" "Name=DBeaver" "$APPS_PATH/io.dbeaver.DBeaver.desktop"
sudo $SCRIPTS_PATH/replace-line.sh "Name=" "Name=Chrome" "$APPS_PATH/google-chrome.desktop"

sudo mv "$APPS_PATH/nm-connection-editor.desktop" $HIDDEN
sudo mv "$APPS_PATH/rofi-theme-selector.desktop" $HIDDEN
sudo mv "$APPS_PATH/thunar-bulk-rename.desktop" $HIDDEN
sudo mv "$APPS_PATH/thunar-settings.desktop" $HIDDEN
sudo mv "$APPS_PATH/avahi-discover.desktop" $HIDDEN
sudo mv "$APPS_PATH/electron27.desktop" $HIDDEN
sudo mv "$APPS_PATH/qvidcap.desktop" $HIDDEN
sudo mv "$APPS_PATH/lstopo.desktop" $HIDDEN
sudo mv "$APPS_PATH/qv4l2.desktop" $HIDDEN
sudo mv "$APPS_PATH/rofi.desktop" $HIDDEN
sudo mv "$APPS_PATH/bssh.desktop" $HIDDEN
sudo mv "$APPS_PATH/bvnc.desktop" $HIDDEN
sudo mv "$APPS_PATH/htop.desktop" $HIDDEN
sudo mv "$APPS_PATH/vim.desktop" $HIDDEN



