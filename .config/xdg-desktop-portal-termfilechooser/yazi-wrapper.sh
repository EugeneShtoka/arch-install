#!/bin/sh
multiple="$1"
directory="$2"
save="$3"
path="$4"
out="$5"

sentinel="/tmp/yazi-chooser-done-$$"
termcmd="wezterm start --always-new-process --"

wait_sentinel() {
    while [ ! -f "$sentinel" ]; do sleep 0.2; done
    rm -f "$sentinel"
}

if [ "$save" = "1" ]; then
    suggest_dir=$(dirname "$path")
    suggest_name=$(basename "$path")

    # Auto-save directories: just use the suggested path, no dialog
    auto_save_dirs="$HOME/Downloads $HOME/Desktop"
    for dir in $auto_save_dirs; do
        case "$suggest_dir" in
            "$dir"|"$dir/"*)
                printf '%s' "$path" > "$out"
                exit 0
                ;;
        esac
    done

    # Otherwise: pick directory in yazi, then type filename in rofi
    cwd_file="/tmp/yazi-cwd-$$"
    $termcmd sh -c 'yazi --cwd-file="$1" "$2"; touch "$3"' -- \
        "$cwd_file" "$suggest_dir" "$sentinel"
    wait_sentinel

    if [ -f "$cwd_file" ]; then
        save_dir=$(cat "$cwd_file")
        rm -f "$cwd_file"
        filename=$(rofi -dmenu -p "Save as:" -filter "$suggest_name")
        if [ -n "$filename" ]; then
            printf '%s/%s' "$save_dir" "$filename" > "$out"
        fi
    fi

elif [ "$directory" = "1" ]; then
    cwd_file="/tmp/yazi-cwd-$$"
    $termcmd sh -c 'yazi --cwd-file="$1" "$2"; touch "$3"' -- \
        "$cwd_file" "${path:-$HOME}" "$sentinel"
    wait_sentinel
    if [ -f "$cwd_file" ]; then
        cat "$cwd_file" > "$out"
        rm -f "$cwd_file"
    fi

elif [ "$multiple" = "1" ]; then
    $termcmd sh -c 'yazi --chooser-file="$1" "$2"; touch "$3"' -- \
        "$out" "${path:-$HOME}" "$sentinel"
    wait_sentinel

else
    $termcmd sh -c 'yazi --chooser-file="$1" "$2"; touch "$3"' -- \
        "$out" "${path:-$HOME}" "$sentinel"
    wait_sentinel
fi
