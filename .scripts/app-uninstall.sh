#!/bin/zsh

package=$1

sudo pacman -R $package --noconfirm
pattern="/auto-yay.sh $package$/d"
sed -i "$pattern" "$SCRIPTS_PATH/apps-install-yay.sh"