#!/bin/bash

# Check if a top-level directory is provided, otherwise use /home/barnacle/Music/
DIR=${1:-/home/barnacle/Music}

# Ensure the directory exists
if [ ! -d "$DIR" ]; then
    echo "Error: Directory '$DIR' does not exist."
    exit 1
fi

# Loop through all subdirectories and files
find "$DIR" -type f -name "*.mp3" | while read -r file; do
    # Get the directory (artist folder) and filename
    dir=$(dirname "$file")
    filename=$(basename "$file")

    # Extract artist from the parent directory name
    artist=$(basename "$dir")

    # Extract title using a flexible pattern (remove artist and .mp3)
    if [[ "$filename" =~ ^(.+?)\ *-\ *"$artist"\.mp3$ ]]; then
        title="${BASH_REMATCH[1]}"
    else
        echo "Skipping $filename: Unrecognized filename format. Expected [Title] - [$artist].mp3"
        continue
    fi

    # Apply metadata using mid3v2
    mid3v2 --artist="$artist" --song="$title" "$file" && echo "Tagged: $file" || echo "Failed to tag: $file"
done

echo "Tagging complete for $DIR and its subfolders."
