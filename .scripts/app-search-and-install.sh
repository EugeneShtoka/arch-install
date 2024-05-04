#!/bin/zsh

package=$1
    IFS=$'\n'
    searchResults=$(yay -Ss $package)
    packages=$(echo $searchResults | awk 'NR % 2 == 1')
    names="aur/tano
aur/sub3dtool-git
aur/gridplayer-appimage
aur/augenkrebs-git
aur/python-vlc-git
aur/npapi-vlc
aur/libvlc-qt
aur/asap-chiptunes-player-git
aur/libvlc-qt-git
aur/syncplay-git
aur/phonon-qt4-vlc\n
aur/vlc-listenbrainz-git
aur/vlc-materia-skin-git
aur/playerctl-git
aur/libvlcpp-git
aur/vlc-plugin-pipewire
aur/vlc-bittorrent-git
aur/python-vlc
aur/vlc-materia-skin
aur/vlc-wayland-git
aur/vlc-plugin-ytdl-git
aur/vlc-pause-click-plugin
aur/vlc-media-context
aur/vlc-bittorrent
aur/freetuxtv
aur/vlc-tunein-radio
aur/vlc-arc-dark-git
aur/npapi-vlc-git
aur/vlc-nox
aur/vlsub-git
aur/vlc-luajit
aur/vlc-git
extra/syncplay
extra/phonon-qt6-vlc
extra/phonon-qt5-vlc
extra/playerctl
extra/vlc"
    echo $names
SAVEIFS=$IFS   # Save current IFS (Internal Field Separator)
IFS=$'\n'      # Change IFS to newline char
names_arr=($names) # split the `names` string into an array by the same name
IFS=$SAVEIFS   # Restore original IFS
    for (( i=0; i<${#names_arr[@]}; i++ ))
    do
        echo "$i: ${names_arr[$i]}"
    done
    versions=${(f)$(echo $packages | awk '{print $2}')}
    descriptions=${(f)$(echo $searchResults | awk 'NR % 2 == 0')}
    # for i in {1..$(echo $names | wc -l)}; do
    #   echo ${names[i]} ${versions[i]} ${descriptions[i]}
    # done

official=$(pacman -Ss "^$package$" | wc -l)
if [[ $official -gt 0 ]]; then
  #sudo pacman -S $package
  echo "Package $package found in official repositories."
else
  aur=$(yay -Ss "^$package$" | wc -l)
  if [[ $aur -gt 0 ]]; then
    #$SCRIPTS_PATH/auto-yay.sh $package
    echo "Package $package found in AUR."
  else
    echo "Package not found in official repositories or AUR."
    searchResults=$(yay -Ss $package)
    echo $searchResults
    echo $(echo $searchResults | awk 'NR % 2 == 0')
  fi
fi