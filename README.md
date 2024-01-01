# arch-install
Install scripts and custom functions for Arch

Manual fixes:
In order to fix a bug with gnome-extensions beign disabled after each reboot:
  1. sudo nano /var/lib/AccountsService/users/eugene
  2. set Session=ubuntu
