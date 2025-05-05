#!/bin/bash

# Usage: ./install_mod.sh <mod_name> <mod_path>

# Check if there are exactly 2 arguments
if [ "$#" -ne 2 ]; then
    echo "Error: Missing arguments"
    echo "Usage: ./install_mod.sh <mod_name> <mod_path>"
    exit 1
fi

# Set variables
MOD_NAME="$1"
MOD_PATH="$2"

# Remove trailing slash or backslash from MOD_PATH
MOD_PATH="${MOD_PATH%/}"
MOD_PATH="${MOD_PATH%\\}"

# Display status
echo "Installing mod: $MOD_NAME"
echo "From path: $MOD_PATH"

# Check if the source directory exists
if [ ! -d "$MOD_PATH" ]; then
    echo "ERROR: Mod path does not exist: $MOD_PATH"
    exit 1
fi

# Set Project Zomboid mods folder
PZ_MODS_DIR="$HOME/Zomboid/mods"

# Ensure the mods folder exists
if [ ! -d "$PZ_MODS_DIR" ]; then
    echo "Creating mods directory: $PZ_MODS_DIR"
    mkdir -p "$PZ_MODS_DIR"
fi

# Set destination directory
TARGET_DIR="$PZ_MODS_DIR/$MOD_NAME"
echo "Installing to: $TARGET_DIR"

# Use rsync to copy mod files
rsync -a --quiet "$MOD_PATH/" "$TARGET_DIR/"

# Check if rsync was successful
if [ $? -ne 0 ]; then
    echo "ERROR: Failed to copy files"
    exit 1
fi

echo "Successfully installed \"$MOD_NAME\" to Project Zomboid mods folder"
echo "Files copied from: $MOD_PATH"
echo "Mod installed to: $TARGET_DIR"

exit 0
