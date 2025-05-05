#!/bin/bash

# Check arguments
if [ "$#" -lt 2 ]; then
    echo "Usage: ./create_mod.sh <mod_name> <mod_path> <optional_folder_names>"
    echo "Example: ./create_mod.sh MyMod \"/path/to/MyMods\" anims animscript AnimSets"
    exit 1
fi

MOD_NAME="$1"
MOD_PATH="$2"

# Create mod base directory
FULL_MOD_PATH="$MOD_PATH/$MOD_NAME"
mkdir -p "$FULL_MOD_PATH"
cd "$FULL_MOD_PATH" || exit

# Create media folder
mkdir -p media

# Write mod.info contents
cat > mod.info << EOF
name=$MOD_NAME
id=$MOD_NAME
description=A new Project Zomboid mod called $MOD_NAME.
poster=poster.png
url=https://theindiestone.com/forums/
EOF

# Create placeholder poster
echo "[Placeholder image file]" > poster.png

# Go into media folder to create subfolders
cd media || exit

# Shift to additional folder arguments
shift 2

# Create subfolders for the remaining arguments
for folder in "$@"; do
    mkdir -p "$folder"
done

echo "Mod $MOD_NAME created successfully at $FULL_MOD_PATH."
