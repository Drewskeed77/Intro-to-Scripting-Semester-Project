#!/bin/bash

# Check minimum arguments
if [ "$#" -lt 4 ]; then
    echo "Usage: $0 <mod_name> <item_type> <item_name> <mod_path> [key=value ...]"
    echo "Example: $0 MyMod Food Apple \"/home/user/ModPath\" Calories=50 HungerChange=-10"
    exit 1
fi

# Assign core arguments
MOD_NAME="$1"
ITEM_TYPE="$2"
ITEM_NAME="$3"
MOD_PATH="$4"
ITEM_ID="$ITEM_NAME"

# Validate item type
VALID_TYPES=("Weapon" "Food" "Clothing" "Literature" "Drainable" "Radio" "AlarmClock" "Key" "Tool")
if [[ ! " ${VALID_TYPES[*]} " =~ " ${ITEM_TYPE} " ]]; then
    echo "Invalid item type: $ITEM_TYPE"
    echo "Valid types: ${VALID_TYPES[*]}"
    exit 1
fi

# Set item script directory
ITEM_DIR="$MOD_PATH/media/scripts"
mkdir -p "$ITEM_DIR"
cd "$ITEM_DIR" || exit 1

# Item script file
ITEM_FILE="$ITEM_DIR/items_${ITEM_TYPE}.txt"

# Create temporary file for the new item definition
TEMP_ITEM=$(mktemp)
{
    echo "    item $ITEM_ID"
    echo "    {"
    echo "        DisplayName = $ITEM_NAME,"
    echo "        Icon = $ITEM_NAME,"
    echo "        Weight = 1.0,"
    echo "        StaticModel = \"\","
    echo "        WorldStaticModel = \"\","
    # Loop through all additional parameters
    for param in "${@:5}"; do
        echo "        $param,"
    done
    echo "    }"
} > "$TEMP_ITEM"

# Append or create item file
if [ -f "$ITEM_FILE" ]; then
    echo "Appending to file: $ITEM_FILE"
    # Check if the file ends with a closing brace
    if [ "$(tail -n 1 "$ITEM_FILE" | tr -d '\n')" != "}" ]; then
        echo "ERROR: Existing file does not end with a closing brace."
        rm "$TEMP_ITEM"
        exit 1
    fi

    TEMP_FULL=$(mktemp)
    # Copy everything except the last line
    head -n -1 "$ITEM_FILE" > "$TEMP_FULL"
    # Append the new item definition and closing brace
    cat "$TEMP_ITEM" >> "$TEMP_FULL"
    echo "}" >> "$TEMP_FULL"
    mv "$TEMP_FULL" "$ITEM_FILE"
else
    echo "Creating new file: $ITEM_FILE"
    {
        echo "module $MOD_NAME {"
        echo "    imports {"
        echo "        Base"
        echo "    }"
        cat "$TEMP_ITEM"
        echo "}"
    } > "$ITEM_FILE"
fi

rm "$TEMP_ITEM"
echo
echo "Successfully created or updated item: $ITEM_NAME"
echo "File path: $ITEM_FILE"