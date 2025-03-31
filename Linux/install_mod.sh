#!/bin/bash
# Usage: ./install_mod.sh <mod_name> <mod_path>

# Check for required arguments
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <mod_name> <mod_path>"
    echo "Example: $0 MyMod /path/to/mod/files"
    exit 1
fi

MOD_NAME=$1
MOD_PATH=$2

# Validate mod path
if [ ! -d "$MOD_PATH" ]; then
    echo "Error: Mod path does not exist: $MOD_PATH"
    exit 1
fi

# Determine Project Zomboid mods directory
PZ_MODS_DIR="$HOME/Zomboid/mods"
if [ ! -d "$PZ_MODS_DIR" ]; then
    echo "Creating mods directory: $PZ_MODS_DIR"
    mkdir -p "$PZ_MODS_DIR"
fi

# Create target directory
TARGET_DIR="$PZ_MODS_DIR/$MOD_NAME"
echo "Installing to: $TARGET_DIR"

# Copy files (with progress)
echo "Copying mod files..."
rsync -a --info=progress2 "$MOD_PATH/" "$TARGET_DIR/"

if [ $? -ne 0 ]; then
    echo "Error: Failed to copy mod files"
    exit 1
fi

echo "Successfully installed $MOD_NAME to Project Zomboid mods folder"
echo "Mod files copied from: $MOD_PATH"
echo "Mod installed to: $TARGET_DIR"