usage() {
    echo "Usage: $0 <source_directory> <target_directory>"
    echo "  <source_directory>: Root directory containing FLAC files."
    echo "  <target_directory>: Directory where ALL MP3 files will be saved."
    exit 1
}

# 2. Check arguments
if [ "$#" -ne 2 ]; then
    echo "Error: Incorrect number of arguments." >&2
    usage
fi

SOURCE_DIR_ARG="$1"
TARGET_DIR_ARG="$2"

# 3. Validate source directory
if [ ! -d "$SOURCE_DIR_ARG" ]; then
    echo "Error: Source directory '$SOURCE_DIR_ARG' not found or is not a directory." >&2
    exit 1
fi

# # Get absolute paths for source and target
# # Use realpath -m for target to handle non-existent paths gracefully for mkdir later
# SOURCE_DIR=$(realpath -- "$SOURCE_DIR_ARG")
# TARGET_DIR=$(realpath -m -- "$TARGET_DIR_ARG")

# 4. Create Target Directory (once, before the loop)
echo "Ensuring target directory exists: $TARGET_DIR"
if ! mkdir -p "$TARGET_DIR"; then
    echo "Error: Could not create target directory '$TARGET_DIR'." >&2
    echo "Please check permissions." >&2
    exit 1
fi

# 5. Find and process FLAC files
echo "Starting FLAC to MP3 conversion..."
echo "Source Directory: $SOURCE_DIR"
echo "Target Directory: $TARGET_DIR (Flat Structure)"

# Use find to locate all .flac files (case-insensitive)
# -print0 and read -d $'\0' handle filenames with spaces, newlines, or special chars safely
find "$SOURCE_DIR" -type f -iname '*.flac' -print0 | while IFS= read -r -d $'\0' flac_file; do
    flac_basename=$(basename -- "$flac_file")
    mp3_basename="${flac_basename%.*}.mp3"
    target_mp3_file="$TARGET_DIR/$mp3_basename"

    echo "Processing Source: '$flac_file'"
    echo "  Target File:     '$target_mp3_file'"

    if [ -f "$target_mp3_file" ]; then
        echo "  Skipping: Target file already exists."
        flac_file_dir=$(dirname -- "$flac_file")
        if [[ "$flac_file_dir" != "$SOURCE_DIR" ]]; then
           echo "  Note: This might be due to a filename collision from different source subdirectories." >&2
        fi
        echo "-------------------------------------------"
        continue
    fi

    echo "  Converting..."

    # Execute ffmpeg conversion
    # -i: input file
    # -nostdin: Prevents ffmpeg from accidentally reading from standard input.
    # -codec:a libmp3lame: Use the LAME MP3 encoder.
    # -q:a 2: Set the VBR quality.
    # -vn: Disable video recording/copying (ensures only audio is processed).
    ffmpeg -nostdin -i "$flac_file" -codec:a libmp3lame -q:a 2 -vn "$target_mp3_file"

    # Check ffmpeg's exit status
    if [ $? -eq 0 ]; then
        echo "  Success!"
    else
        echo "  Error: ffmpeg failed to convert '$flac_file'. Check ffmpeg output." >&2
        # remove partially created/failed mp3 file
        rm -f "$target_mp3_file"
    fi
    echo "-------------------------------------------"

done

echo "Conversion process finished."
exit 0