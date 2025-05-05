#!/bin/bash

# === Capture arguments ===
MOD_NAME="$1"
RECIPE_NAME="$2"
RECIPE_TYPE="$3"
RESULT_ITEM="$4"
RESULT_COUNT="$5"
RECIPE_TIME="$6"
INGREDIENTS="$7"
SKILL_TYPE="$8"
SKILL_LEVEL="$9"

# === Workaround to grab the 10th argument (MOD_PATH) ===
MOD_PATH="${@:10}"

# === Remove quotes if present ===
MOD_PATH="${MOD_PATH//\"/}"

# === Define paths ===
SCRIPTS_DIR="$MOD_PATH/media/scripts"
RECIPE_FILE="$SCRIPTS_DIR/${MOD_NAME}_Recipes.txt"
TEMP_RECIPE=$(mktemp)
TEMP_FINAL=$(mktemp)

# === Ensure directories exist ===
if [ ! -d "$SCRIPTS_DIR" ]; then
    echo "Creating directory structure..."
    mkdir -p "$SCRIPTS_DIR"
fi

# === Create recipe file if not exist ===
if [ ! -f "$RECIPE_FILE" ]; then
    echo "Creating new recipe file with module Base block..."
    cat <<EOF > "$RECIPE_FILE"
module Base
{
}
EOF
fi

# === Create the recipe block in a temp file ===
{
    echo
    echo "recipe $RECIPE_NAME {"
} > "$TEMP_RECIPE"

# === Add ingredients ===
IFS=',' read -ra INGREDIENT_ARRAY <<< "$INGREDIENTS"
for ITEM in "${INGREDIENT_ARRAY[@]}"; do
    IFS=':' read -ra ITEM_PARTS <<< "$ITEM"
    if [ -n "${ITEM_PARTS[0]}" ] && [ -n "${ITEM_PARTS[1]}" ]; then
        echo "    ${ITEM_PARTS[1]} ${ITEM_PARTS[0]}," >> "$TEMP_RECIPE"
    fi
done

# === Add result, time, and category ===
echo "    Result:$RESULT_ITEM=$RESULT_COUNT," >> "$TEMP_RECIPE"
echo "    Time:$RECIPE_TIME," >> "$TEMP_RECIPE"
echo "    Category:$RECIPE_TYPE," >> "$TEMP_RECIPE"

# === Add skill only if provided ===
if [ -n "$SKILL_TYPE" ]; then
    SKILL_TYPE_CLEANED="${SKILL_TYPE// /}"
    echo "    SkillRequired:$SKILL_TYPE_CLEANED=$SKILL_LEVEL," >> "$TEMP_RECIPE"
fi

# === Close recipe block ===
echo "}" >> "$TEMP_RECIPE"

# === Insert recipe into the file, just before the final '}' ===
INSERTION_DONE=0
{
    while IFS= read -r line; do
        echo "$line"
        if [ "$line" == "}" ] && [ "$INSERTION_DONE" -eq 0 ]; then
            cat "$TEMP_RECIPE" >> "$TEMP_FINAL"
            INSERTION_DONE=1
        fi
    done < "$RECIPE_FILE"
} > "$TEMP_FINAL"

# === Overwrite original file ===
mv -f "$TEMP_FINAL" "$RECIPE_FILE"

# === Clean up temporary files ===
rm -f "$TEMP_RECIPE"

echo "Successfully added recipe '$RECIPE_NAME' to '$RECIPE_FILE'"
exit 0
