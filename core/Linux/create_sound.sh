#!/bin/bash

# === Core arguments ===
MOD_NAME="$1"
SOUND_TYPE="$2"
SOUND_NAME="$3"
MOD_PATH="$4"

# === Paths ===
SCRIPTS_DIR="$MOD_PATH/media/scripts"
SOUND_FILE="$SCRIPTS_DIR/sounds_${SOUND_TYPE}.txt"

# Ensure the directory exists
mkdir -p "$SCRIPTS_DIR"

# Check if the file exists
IS_APPEND=false
if [ -f "$SOUND_FILE" ]; then
    IS_APPEND=true
fi

# Create temporary file for the sound definition
TEMP_FILE=$(mktemp)
{
    echo
    echo "    sound $SOUND_NAME {"
    echo "        category = Player,"
    echo "        loop = true,"
    echo "        is3D = true,"
    echo "        clip {"
    echo "            file = media/sound/$SOUND_NAME.ogg,"
    echo "            distanceMax = 6,"
    echo "            reverbFactor = 0.1,"
    echo "            volume = 0.7,"
    echo "        }"
} > "$TEMP_FILE"

# === Parse key=value pairs ===
shift 3
while [ -n "$1" ]; do
    IFS='=' read -r key value <<< "$1"
    if [ -n "$key" ] && [ -n "$value" ]; then
        # Check if it's a clip property
        if [[ "$key" =~ ^(distanceMax|reverbFactor|volume|file)$ ]]; then
            # It's a clip property, indented more
            sed -i "/$key/s/=.*/= $value,/" "$TEMP_FILE"
        else
            # It's a regular sound property
            echo "        $key = $value," >> "$TEMP_FILE"
        fi
    fi
    shift
done

# Close the sound block
echo "    }" >> "$TEMP_FILE"

# === Insert sound block into the file ===
if [ "$IS_APPEND" = true ]; then
    echo "Appending to file: $SOUND_FILE"
    
    # Check if file ends with closing brace
    if ! tail -n 1 "$SOUND_FILE" | grep -q '}'; then
        echo "ERROR: Existing file does not end with a closing brace."
        exit 1
    fi

    # Create a temporary file without the closing brace
    TEMP_FULL=$(mktemp)
    
    # Copy everything except the last line (closing brace)
    head -n -1 "$SOUND_FILE" > "$TEMP_FULL"
    
    # Add the new sound block
    cat "$TEMP_FILE" >> "$TEMP_FULL"
    
    # Add the closing brace
    echo "}" >> "$TEMP_FULL"
    
    # Replace the original file
    mv -f "$TEMP_FULL" "$SOUND_FILE"
else
    echo "Creating new file: $SOUND_FILE"
    
    # Create file with module header
    {
        echo "module $MOD_NAME {"
        cat "$TEMP_FILE"
        echo "}"
    } > "$SOUND_FILE"
fi

# Clean up temporary file
rm -f "$TEMP_FILE"

echo "Successfully created or updated sound: $SOUND_NAME"
echo "File path: $SOUND_FILE"
exit 0
