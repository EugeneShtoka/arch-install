#!/bin/zsh
sudo /usr/local/sbin/netns-banking-setup
exec sudo ip netns exec direct sudo -u eugene \
  env DISPLAY=:0 XAUTHORITY=$HOME/.Xauthority \
  vivaldi --user-data-dir=$HOME/.config/vivaldi-banking "$@"
