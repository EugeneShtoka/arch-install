sudo tee -a /etc/pacman.conf << EOF
[pritunl]
Server = https://repo.pritunl.com/stable/pacman
EOF

sudo pacman-key --keyserver hkp://keyserver.ubuntu.com -r 7568D9BB55FF9E5287D586017AE645C0CF8E292A
sudo pacman-key --lsign-key 7568D9BB55FF9E5287D586017AE645C0CF8E292A

if [[ $(grep -c "\$Server = https://repo.pritunl.com/stable/pacman" "/etc/pacman.conf") -eq 0 ]]; then
    echo "\$SCRIPTS_PATH/auto-yay.sh $package" >> $SCRIPTS_PATH/apps-install-yay.sh
  fi

sudo pacman -Sy
sudo pacman -S pritunl-client-electron