#!/bin/zsh

model="u2net"
rembg_flags=""

while [[ $1 == -* ]]; do
    case $1 in
        -light)  model="u2netp" ;;
        -refine) rembg_flags="$rembg_flags --alpha-matting" ;;
        *) echo "Unknown flag: $1" >&2; exit 1 ;;
    esac
    shift
done

src=$1
[[ -z $src ]] && { echo "Usage: rembg-remote [-light] [-refine] <image> [output]" >&2; exit 1; }
[[ ! -f $src ]] && { echo "Error: file not found: $src" >&2; exit 1; }

filename=$(basename $src)
stem=${filename%.*}
ts=$(date +%Y%m%d_%H%M%S)
out=${2:-"$(dirname $src)/${stem}-nobg-${ts}.png"}
remote="/tmp/rembg-$$-${filename}"
remote_out="/tmp/rembg-$$-${stem}-nobg.png"

echo "Uploading..."
command scp -q "$src" vps:${remote}

echo "Removing background..."
ssh vps "sudo podman run --rm -v /tmp:/data danielgatis/rembg i -m ${model} ${rembg_flags} /data/$(basename $remote) /data/$(basename $remote_out)"

echo "Downloading..."
command scp -q vps:${remote_out} "$out"

ssh vps "sudo rm -f ${remote} ${remote_out}"

echo -n "$out" | xclip -selection clipboard
echo "Done: $out"
