#!/bin/zsh
sudo /home/eugene/.scripts/netns-banking-setup.sh
exec sudo ip netns exec direct sudo -u eugene \
  env DISPLAY=:0 XAUTHORITY=$HOME/.Xauthority \
  vivaldi --user-data-dir=$HOME/.config/vivaldi-banking "$@"
