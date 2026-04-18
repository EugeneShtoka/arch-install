#!/bin/zsh
/usr/bin/xclip -o -selection clipboard \
  | /home/eugene/go/bin/clipkit --collapse --strip-borders --strip-timestamps \
  | /usr/bin/xclip -i -selection clipboard \
&& xdotool key --clearmodifiers ctrl+v
