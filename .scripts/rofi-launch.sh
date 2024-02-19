dir="$HOME/.config/rofi/launchers/type-4"
theme='style-10'

## Run
rofi \
    -show drun \
    -theme ${dir}/${theme}.rasi \
    -run-list-command \". $SCRIPTS_PATH/list-functions.sh\" -run-command \"/bin/zsh -i -c '{cmd}'\" -rnow