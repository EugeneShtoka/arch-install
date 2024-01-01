#!/bin/zsh
APPS_PATH=/usr/share/applications
HIDDEN=$APPS_PATH-hidden
mkdir HIDDEN

sudo $SCRIPTS_PATH/replace-line.sh "Icon=" "Icon=$ICON_PATH/terminal.png" "$APPS_PATH/kitty.desktop"
sudo $SCRIPTS_PATH/replace-line.sh "Name=" "Name=Terminal" "$APPS_PATH/kitty.desktop"
sudo $SCRIPTS_PATH/replace-line.sh "Icon=" "Icon=$ICON_PATH/file-manager.png" "$APPS_PATH/thunar.desktop"
sudo $SCRIPTS_PATH/replace-line.sh "Name=" "Name=File Manager" "$APPS_PATH/thunar.desktop"
sudo $SCRIPTS_PATH/replace-line.sh "Name=" "Name=VS Code" "$APPS_PATH/code.desktop"
sudo $SCRIPTS_PATH/replace-line.sh "theme='style-1'" "theme='style-2'" "$HOME/.config/rofi/powermenu/"

sudo mv "$APPS_PATH/nm-connection-editor.desktop" "$HIDDEN/nm-connection-editor.desktop"
sudo mv "$APPS_PATH/thunar-bulk-rename.desktop" "$HIDDEN/thunar-bulk-rename.desktop"
sudo mv "$APPS_PATH/thunar-settings.desktop" "$HIDDEN/thunar-settings.desktop"
sudo mv "$APPS_PATH/lstopo.desktop" "$HIDDEN/lstopo.desktop"
sudo mv "$APPS_PATH/vim.desktop" "$HIDDEN/vim.desktop"
