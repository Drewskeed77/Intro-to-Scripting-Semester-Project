@echo off
:: Creates complete item files with all common properties
:: Usage: create_item.bat <mod_name> <item_type> <item_name>

setlocal enabledelayedexpansion

:: Check arguments
if "%~3"=="" (
    echo Usage: create_item.bat ^<mod_name^> ^<item_type^> ^<item_name^>
    echo Example: create_item.bat MyMod Weapon BaseballBat
    exit /b 1
)

set MOD_NAME=%~1
set ITEM_TYPE=%~2
set ITEM_NAME=%~3
set ITEM_ID=%MOD_NAME%.%ITEM_NAME%

:: Validate item type
set VALID_TYPES=Weapon Food Clothing Literature Drainable Radio AlarmClock Key Tool
echo %VALID_TYPES% | find /i "%ITEM_TYPE%" > nul
if errorlevel 1 (
    echo Invalid item type: %ITEM_TYPE%
    echo Valid types: %VALID_TYPES%
    exit /b 1
)

:: Create directories if they don't exist
set ITEM_DIR=%~dp0..\%MOD_NAME%\media\scripts\items
if not exist "!ITEM_DIR!" (
    mkdir "!ITEM_DIR!"
)

:: Create the item file
set ITEM_FILE=!ITEM_DIR!\%ITEM_TYPE%_%ITEM_NAME%.txt
echo Creating item file: !ITEM_FILE!

:: Common properties
echo module Base > "!ITEM_FILE!"
echo item !ITEM_ID! >> "!ITEM_FILE!"
echo { >> "!ITEM_FILE!"
echo     DisplayName = !ITEM_NAME!, >> "!ITEM_FILE!"
echo     Icon = !ITEM_NAME!, >> "!ITEM_FILE!"
echo     Weight = 1.0, >> "!ITEM_FILE!"

:: Type-specific properties
if /i "!ITEM_TYPE!"=="Weapon" (
    echo     WeaponSprite = !ITEM_NAME!_weapon, >> "!ITEM_FILE!"
    echo     MinAngle = 0.5, >> "!ITEM_FILE!"
    echo     Type = Weapon, >> "!ITEM_FILE!"
    echo     MinimumSwingTime = 2.0, >> "!ITEM_FILE!"
    echo     SwingAmountBeforeImpact = 0.02, >> "!ITEM_FILE!"
    echo     Categories = Blunt, >> "!ITEM_FILE!"
    echo     ConditionLowerChanceOneIn = 30, >> "!ITEM_FILE!"
    echo     ConditionMax = 10, >> "!ITEM_FILE!"
    echo     MaxHitCount = 2, >> "!ITEM_FILE!"
    echo     DoorDamage = 5, >> "!ITEM_FILE!"
    echo     TreeDamage = 2, >> "!ITEM_FILE!"
    echo     EnduranceMod = 1.0, >> "!ITEM_FILE!"
    echo     MetalValue = 25, >> "!ITEM_FILE!"
)

if /i "!ITEM_TYPE!"=="Food" (
    echo     Type = Food, >> "!ITEM_FILE!"
    echo     HungerChange = -10, >> "!ITEM_FILE!"
    echo     UnhappyChange = 0, >> "!ITEM_FILE!"
    echo     BoredomChange = 0, >> "!ITEM_FILE!"
    echo     Calories = 150, >> "!ITEM_FILE!"
    echo     Carbohydrates = 15.0, >> "!ITEM_FILE!"
    echo     Proteins = 5.0, >> "!ITEM_FILE!"
    echo     Lipids = 2.0, >> "!ITEM_FILE!"
    echo     DaysFresh = 3, >> "!ITEM_FILE!"
    echo     DaysTotallyRotten = 7, >> "!ITEM_FILE!"
    echo     Poison = false, >> "!ITEM_FILE!"
    echo     PoisonDetectionLevel = 0, >> "!ITEM_FILE!"
)

if /i "!ITEM_TYPE!"=="Clothing" (
    echo     Type = Clothing, >> "!ITEM_FILE!"
    echo     BodyLocation = Jacket, >> "!ITEM_FILE!"
    echo     WorldStaticModel = , >> "!ITEM_FILE!"
    echo     Insulation = 0.5, >> "!ITEM_FILE!"
    echo     WindResistance = 0.5, >> "!ITEM_FILE!"
    echo     WaterResistance = 0, >> "!ITEM_FILE!"
    echo     BiteDefense = 0, >> "!ITEM_FILE!"
    echo     ScratchDefense = 0, >> "!ITEM_FILE!"
    echo     BloodLocation = Jacket, >> "!ITEM_FILE!"
    echo     RunSpeedModifier = 1.0, >> "!ITEM_FILE!"
    echo     CombatSpeedModifier = 1.0, >> "!ITEM_FILE!"
)

if /i "!ITEM_TYPE!"=="Literature" (
    echo     Type = Literature, >> "!ITEM_FILE!"
    echo     PageNumber = 1, >> "!ITEM_FILE!"
    echo     CanBeWrite = true, >> "!ITEM_FILE!"
    echo     Skill = , >> "!ITEM_FILE!"
    echo     Level = 0, >> "!ITEM_FILE!"
    echo     NumLevelsTrained = 1, >> "!ITEM_FILE!"
    echo     Recipe = , >> "!ITEM_FILE!"
    echo     TeachedRecipes = , >> "!ITEM_FILE!"
)

if /i "!ITEM_TYPE!"=="Drainable" (
    echo     Type = Drainable, >> "!ITEM_FILE!"
    echo     UseWhileEquipped = false, >> "!ITEM_FILE!"
    echo     UseDelta = 0.1, >> "!ITEM_FILE!"
    echo     ReplaceOnDeplete = , >> "!ITEM_FILE!"
    echo     TicksPerEquipUse = 10, >> "!ITEM_FILE!"
    echo     CantBeFilled = false, >> "!ITEM_FILE!"
)

if /i "!ITEM_TYPE!"=="Radio" (
    echo     Type = Radio, >> "!ITEM_FILE!"
    echo     IsPortable = true, >> "!ITEM_FILE!"
    echo     IsTelevision = false, >> "!ITEM_FILE!"
    echo     MinChannelRange = 8800, >> "!ITEM_FILE!"
    echo     MaxChannelRange = 10800, >> "!ITEM_FILE!"
    echo     TwoWay = false, >> "!ITEM_FILE!"
    echo     BaseVolumeRange = 10, >> "!ITEM_FILE!"
)

if /i "!ITEM_TYPE!"=="AlarmClock" (
    echo     Type = AlarmClock, >> "!ITEM_FILE!"
    echo     AlarmSound = , >> "!ITEM_FILE!"
    echo     AlarmTime = 0, >> "!ITEM_FILE!"
    echo     AlarmSet = false, >> "!ITEM_FILE!"
)

if /i "!ITEM_TYPE!"=="Key" (
    echo     Type = Key, >> "!ITEM_FILE!"
    echo     KeyId = -1, >> "!ITEM_FILE!"
)

if /i "!ITEM_TYPE!"=="Tool" (
    echo     Type = Tool, >> "!ITEM_FILE!"
    echo     Tooltip = Tooltip_item, >> "!ITEM_FILE!"
    echo     CriticalChance = 0, >> "!ITEM_FILE!"
    echo     ConditionLowerChanceOneIn = 30, >> "!ITEM_FILE!"
    echo     Uses = 10, >> "!ITEM_FILE!"
)

echo } >> "!ITEM_FILE!"

echo.
echo Successfully created !ITEM_TYPE% item "!ITEM_NAME!" for mod "!MOD_NAME!"
echo File created at: "!ITEM_FILE!"
echo.
echo Next steps:
echo 1. Add textures in media/textures/!ITEM_NAME!.png
echo 2. Create translations in media/lua/shared/Translate/EN/!ITEM_NAME!.txt
echo 3. Update any specific properties in !ITEM_FILE!
echo 4. Add to recipes.txt if this item is used in crafting
echo 5. Test in-game!
echo.

endlocal