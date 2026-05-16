#!/bin/zsh

sudo cp $SCRIPTS_PATH/udev-rules/*.rules /etc/udev/rules.d/
sudo udevadm control --reload
