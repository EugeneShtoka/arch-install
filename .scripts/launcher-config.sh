#!/bin/zsh

APPS_PATH=/usr/share/applications
APPS_LOCAL_PATH=~/.local/share/applications
HIDDEN=$APPS_PATH-hidden
mkdir $HIDDEN

sudo $SCRIPTS_PATH/replace-line.sh "theme='style-1'" "theme='style-10'" "$HOME/.config/rofi/launchers/type-4/launcher.sh"
sed '$d' "$HOME/.config/rofi/launchers/type-4/launcher.sh" > "$HOME/.config/rofi/launchers/type-4/launcher.sh"
echo " -run-list-command \". $SCRIPTS_PATH/list-functions.sh\" -run-command \"/bin/zsh -i -c '{cmd}'\" -rnow " >> "$HOME/.config/rofi/launchers/type-4/launcher.sh"       

sudo $SCRIPTS_PATH/replace-line.sh "Icon=" "Icon=$ICON_PATH/terminal.png" "$APPS_PATH/kitty.desktop"
sudo $SCRIPTS_PATH/replace-line.sh "Name=" "Name=Terminal" "$APPS_PATH/kitty.desktop"
sudo $SCRIPTS_PATH/replace-line.sh "Icon=" "Icon=$ICON_PATH/file-manager.png" "$APPS_PATH/thunar.desktop"
sudo $SCRIPTS_PATH/replace-line.sh "Name=" "Name=Mail" "$APPS_PATH/Mailspring.desktop"
sudo $SCRIPTS_PATH/replace-line.sh "Exec=" "Exec=$SCRIPTS_PATH/mailspring-start.sh" "$APPS_PATH/Mailspring.desktop"
sudo $SCRIPTS_PATH/replace-line.sh "Name=" "Name=File Manager" "$APPS_PATH/thunar.desktop"
sudo $SCRIPTS_PATH/replace-line.sh "Name=" "Name=Code Editor" "$APPS_PATH/code.desktop"
sudo $SCRIPTS_PATH/replace-line.sh "Name=" "Name=DB Tool" "$APPS_PATH/io.dbeaver.DBeaver.desktop"
sudo $SCRIPTS_PATH/replace-line.sh "Exec=" "Exec=$SCRIPTS_PATH/dbeaver-start.sh" "$APPS_PATH/io.dbeaver.DBeaver.desktop"
sudo $SCRIPTS_PATH/replace-line.sh "Name=" "Name=Browser" "$APPS_PATH/vivaldi-snapshot.desktop"
sudo $SCRIPTS_PATH/replace-line.sh "Name=" "Name=Docker" "$APPS_PATH/docker-desktop.desktop"
sudo $SCRIPTS_PATH/replace-line.sh "Name=" "Name=Torrent" "$APPS_PATH/org.qbittorrent.qBittorrent.desktop"
sudo $SCRIPTS_PATH/replace-line.sh "Name=" "Name=Messenger" "$APPS_PATH/beeper.desktop"
sudo $SCRIPTS_PATH/replace-line.sh "Name=" "Name=Notes" "$APPS_PATH/obsidian.desktop"
sudo $SCRIPTS_PATH/replace-line.sh "Name=" "Name=Slack" "$APPS_PATH/slack.desktop"
sudo $SCRIPTS_PATH/replace-line.sh "Name=" "Name=Automation" "$APPS_PATH/autokey-gtk.desktop"
sudo $SCRIPTS_PATH/replace-line.sh "Name=" "Name=Steam" "$APPS_PATH/steam.desktop"
sudo $SCRIPTS_PATH/replace-line.sh "Name=" "Name=Together" "$APPS_LOCAL_PATH/dont-starve-together.desktop"

sudo mv "$APPS_PATH/nm-connection-editor.desktop" $HIDDEN
sudo mv "$APPS_PATH/rofi-theme-selector.desktop" $HIDDEN

sudo mv "$APPS_PATH/thunar-bulk-rename.desktop" $HIDDEN
sudo mv "$APPS_PATH/thunar-settings.desktop" $HIDDEN
sudo mv "$APPS_PATH/avahi-discover.desktop" $HIDDEN
sudo mv "$APPS_PATH/electron25.desktop" $HIDDEN
sudo mv "$APPS_PATH/electron28.desktop" $HIDDEN
sudo mv "$APPS_PATH/qvidcap.desktop" $HIDDEN
sudo mv "$APPS_PATH/lstopo.desktop" $HIDDEN
sudo mv "$APPS_PATH/qv4l2.desktop" $HIDDEN
sudo mv "$APPS_PATH/rofi.desktop" $HIDDEN
sudo mv "$APPS_PATH/bssh.desktop" $HIDDEN
sudo mv "$APPS_PATH/bvnc.desktop" $HIDDEN
sudo mv "$APPS_PATH/htop.desktop" $HIDDEN
sudo mv "$APPS_PATH/vim.desktop" $HIDDEN



