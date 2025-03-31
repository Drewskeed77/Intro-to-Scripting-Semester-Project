#!/bin/bash
# Creates complete item files with all common properties
# Usage: ./create_item.sh <mod_name> <item_type> <item_name>

# Check arguments
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <mod_name> <item_type> <item_name>"
    echo "Example: $0 MyMod Weapon BaseballBat"
    exit 1
fi

MOD_NAME="$1"
ITEM_TYPE="$2"
ITEM_NAME="$3"
ITEM_ID="${MOD_NAME}.${ITEM_NAME}"

# Validate item type
VALID_TYPES=("Weapon" "Food" "Clothing" "Literature" "Drainable" "Radio" "AlarmClock" "Key" "Tool")
if [[ ! " ${VALID_TYPES[@]} " =~ " ${ITEM_TYPE} " ]]; then
    echo "Invalid item type: $ITEM_TYPE"
    echo "Valid types: ${VALID_TYPES[@]}"
    exit 1
fi

# Create directories if they don't exist
ITEM_DIR="$(dirname "$0")/../${MOD_NAME}/media/scripts/items"
mkdir -p "$ITEM_DIR"

# Create the item file
ITEM_FILE="${ITEM_DIR}/${ITEM_TYPE}_${ITEM_NAME}.txt"
echo "Creating item file: $ITEM_FILE"

# Common properties
cat > "$ITEM_FILE" <<EOL
module Base
item $ITEM_ID
{
    DisplayName = $ITEM_NAME,
    Icon = $ITEM_NAME,
    Weight = 1.0,
EOL

# Type-specific properties
case "$ITEM_TYPE" in
    "Weapon")
        cat >> "$ITEM_FILE" <<EOL
    WeaponSprite = ${ITEM_NAME}_weapon,
    MinAngle = 0.5,
    Type = Weapon,
    MinimumSwingTime = 2.0,
    SwingAmountBeforeImpact = 0.02,
    Categories = Blunt,
    ConditionLowerChanceOneIn = 30,
    ConditionMax = 10,
    MaxHitCount = 2,
    DoorDamage = 5,
    TreeDamage = 2,
    EnduranceMod = 1.0,
    MetalValue = 25,
EOL
        ;;

    "Food")
        cat >> "$ITEM_FILE" <<EOL
    Type = Food,
    HungerChange = -10,
    UnhappyChange = 0,
    BoredomChange = 0,
    Calories = 150,
    Carbohydrates = 15.0,
    Proteins = 5.0,
    Lipids = 2.0,
    DaysFresh = 3,
    DaysTotallyRotten = 7,
    Poison = false,
    PoisonDetectionLevel = 0,
EOL
        ;;

    "Clothing")
        cat >> "$ITEM_FILE" <<EOL
    Type = Clothing,
    BodyLocation = Jacket,
    WorldStaticModel = ,
    Insulation = 0.5,
    WindResistance = 0.5,
    WaterResistance = 0,
    BiteDefense = 0,
    ScratchDefense = 0,
    BloodLocation = Jacket,
    RunSpeedModifier = 1.0,
    CombatSpeedModifier = 1.0,
EOL
        ;;

    "Literature")
        cat >> "$ITEM_FILE" <<EOL
    Type = Literature,
    PageNumber = 1,
    CanBeWrite = true,
    Skill = ,
    Level = 0,
    NumLevelsTrained = 1,
    Recipe = ,
    TeachedRecipes = ,
EOL
        ;;

    "Drainable")
        cat >> "$ITEM_FILE" <<EOL
    Type = Drainable,
    UseWhileEquipped = false,
    UseDelta = 0.1,
    ReplaceOnDeplete = ,
    TicksPerEquipUse = 10,
    CantBeFilled = false,
EOL
        ;;

    "Radio")
        cat >> "$ITEM_FILE" <<EOL
    Type = Radio,
    IsPortable = true,
    IsTelevision = false,
    MinChannelRange = 8800,
    MaxChannelRange = 10800,
    TwoWay = false,
    BaseVolumeRange = 10,
EOL
        ;;

    "AlarmClock")
        cat >> "$ITEM_FILE" <<EOL
    Type = AlarmClock,
    AlarmSound = ,
    AlarmTime = 0,
    AlarmSet = false,
EOL
        ;;

    "Key")
        cat >> "$ITEM_FILE" <<EOL
    Type = Key,
    KeyId = -1,
EOL
        ;;

    "Tool")
        cat >> "$ITEM_FILE" <<EOL
    Type = Tool,
    Tooltip = Tooltip_item,
    CriticalChance = 0,
    ConditionLowerChanceOneIn = 30,
    Uses = 10,
EOL
        ;;
esac

# Close the item definition
echo "}" >> "$ITEM_FILE"

echo -e "\nSuccessfully created $ITEM_TYPE item \"$ITEM_NAME\" for mod \"$MOD_NAME\""
echo "File created at: $ITEM_FILE"
echo -e "\nNext steps:"
echo "1. Add textures in media/textures/${ITEM_NAME}.png"
echo "2. Create translations in media/lua/shared/Translate/EN/${ITEM_NAME}.txt"
echo "3. Update any specific properties in $ITEM_FILE"
echo "4. Add to recipes.txt if this item is used in crafting"
echo "5. Test in-game!"
echo