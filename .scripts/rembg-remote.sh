#!/bin/zsh

src=$1
[[ -z $src ]] && { echo "Usage: rembg-remote <image> [output]" >&2; exit 1; }
[[ ! -f $src ]] && { echo "Error: file not found: $src" >&2; exit 1; }

filename=$(basename $src)
stem=${filename%.*}
ts=$(date +%Y%m%d_%H%M%S)
out=${2:-"$(dirname $src)/${stem}-nobg-${ts}.png"}
remote="/tmp/rembg-$$-${filename}"
remote_out="/tmp/rembg-$$-${stem}-nobg.png"

echo "Uploading..."
command scp -q -P 47293 -i ~/.ssh/hetzner_vps "$src" eugene@65.21.3.202:${remote}

echo "Removing background..."
ssh hetzner "sudo podman run --rm -v /tmp:/data danielgatis/rembg i /data/$(basename $remote) /data/$(basename $remote_out)"

echo "Downloading..."
command scp -q -P 47293 -i ~/.ssh/hetzner_vps eugene@65.21.3.202:${remote_out} "$out"

ssh hetzner "sudo rm -f ${remote} ${remote_out}"

echo "Done: $out"
