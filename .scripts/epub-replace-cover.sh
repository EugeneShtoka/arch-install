#!/bin/zsh
# epub-replace-cover.sh <book.epub> <cover-image>
# Replaces the cover image in an EPUB file in-place.

epub=$1
cover=$2

if [[ -z $epub || -z $cover ]]; then
  echo "Usage: epub-replace-cover.sh <book.epub> <cover-image>"
  exit 1
fi

if [[ ! -f $epub ]]; then
  echo "Error: epub not found: $epub"
  exit 1
fi

if [[ ! -f $cover ]]; then
  echo "Error: cover image not found: $cover"
  exit 1
fi

tmpdir=$(mktemp -d)
trap "rm -rf $tmpdir" EXIT

# Find OPF path from container.xml
opf_path=$(unzip -p "$epub" META-INF/container.xml | grep -oP 'full-path="\K[^"]+')
if [[ -z $opf_path ]]; then
  echo "Error: could not find OPF path in container.xml"
  exit 1
fi

opf_dir=${opf_path:h}  # dirname
opf_content=$(unzip -p "$epub" "$opf_path")

# Try EPUB3: item with properties="cover-image"
cover_href=$(echo "$opf_content" | grep -oP '<item[^>]+properties="cover-image"[^>]+>' | grep -oP 'href="\K[^"]+')

# Try EPUB2: <meta name="cover" content="ID"/> -> find item by id
if [[ -z $cover_href ]]; then
  cover_id=$(echo "$opf_content" | grep -oP '<meta name="cover" content="\K[^"]+')
  if [[ -n $cover_id ]]; then
    cover_href=$(echo "$opf_content" | grep -oP "<item[^>]+id=\"${cover_id}\"[^>]+" | grep -oP 'href="\K[^"]+')
  fi
fi

if [[ -z $cover_href ]]; then
  echo "Error: could not detect cover image in OPF manifest"
  exit 1
fi

# Build full path inside zip
if [[ $opf_dir == "." ]]; then
  cover_zip_path=$cover_href
else
  cover_zip_path=$opf_dir/$cover_href
fi

echo "Cover image in EPUB: $cover_zip_path"

# Extract, replace, repack
unzip -q "$epub" -d "$tmpdir"
cp "$cover" "$tmpdir/$cover_zip_path"

out=$(mktemp --suffix=.epub)
(cd "$tmpdir" && zip -qX "$out" mimetype && zip -qrg "$out" $(ls | grep -v '^mimetype$'))

# Verify
if ! zip -T "$out" > /dev/null 2>&1; then
  echo "Error: resulting EPUB failed ZIP integrity check"
  rm -f "$out"
  exit 1
fi

cp "$epub" "${epub}.bak"
mv "$out" "$epub"
echo "Done. Backup: ${epub}.bak"
