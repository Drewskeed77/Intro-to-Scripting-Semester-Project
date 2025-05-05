#!/bin/bash

# Arguments
MOD_NAME="$1"
MOD_PATH="$2"
MODEL_NAME="$3"

# Config file path
CONFIG_FILE="$MOD_PATH/media/scripts/models.txt"

# Make sure directories exist
if [ ! -d "$MOD_PATH/media/scripts" ]; then
    echo "Creating directory structure..."
    mkdir -p "$MOD_PATH/media/scripts"
fi

# If file doesn't exist, create with module header
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Creating new config file with module header..."
    cat <<EOF > "$CONFIG_FILE"
module Base
{
}
EOF
fi

# Model block to insert
MODEL_BLOCK=$(cat <<EOF
    model $MODEL_NAME
    {
        mesh = WorldItems/$MODEL_NAME,
        texture = WorldItems/$MODEL_NAME,
        scale = 1,
    }
EOF
)

# Temporary output file
TEMP_FILE="$MOD_PATH/media/scripts/models_temp.txt"
INSERTION_DONE=0

# Read and rewrite original file, insert model before the final '}'
{
    while IFS= read -r line; do
        echo "$line"
        if [ "$line" == "}" ] && [ "$INSERTION_DONE" -eq 0 ]; then
            echo "$MODEL_BLOCK"
            INSERTION_DONE=1
        fi
    done < "$CONFIG_FILE"
} > "$TEMP_FILE"

# Replace original file with updated version
mv -f "$TEMP_FILE" "$CONFIG_FILE"

# Check if the file exists after operations
if [ -f "$CONFIG_FILE" ]; then
    echo "Model '$MODEL_NAME' added to '$CONFIG_FILE'"
    exit 0
else
    echo "ERROR: Failed to create or update '$CONFIG_FILE'"
    echo "MOD_PATH is set to: $MOD_PATH"
    echo "Full config path: $CONFIG_FILE"
    exit 1
fi
