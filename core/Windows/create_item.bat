@echo off
setlocal enabledelayedexpansion
:: Check minimum arguments
if "%~4"=="" (
    echo Usage: create_item.bat ^<mod_name^> ^<item_type^> ^<item_name^> ^<mod_path^> [key=value ...]
    echo Example: create_item.bat MyMod Food Apple "C:\ModPath" Calories=50 HungerChange=-10
    exit /b 1
)
:: Assign core arguments
set "MOD_NAME=%~1"
set "ITEM_TYPE=%~2"
set "ITEM_NAME=%~3"
set "MOD_PATH=%~4"
set "ITEM_ID=%ITEM_NAME%"
:: Validate item type
set "VALID_TYPES=Weapon Food Clothing Literature Drainable Radio AlarmClock Key Tool"
echo %VALID_TYPES% | find /i "%ITEM_TYPE%" > nul
if errorlevel 1 (
    echo Invalid item type: %ITEM_TYPE%
    echo Valid types: %VALID_TYPES%
    exit /b 1
)
:: Set item script directory
set "ITEM_DIR=%MOD_PATH%\media\scripts"
if not exist "!ITEM_DIR!" mkdir "!ITEM_DIR!"
cd /d "!ITEM_DIR!"
:: Item script file
set "ITEM_FILE=%ITEM_DIR%\items_%ITEM_TYPE%.txt"
:: Check if file exists and if it's already being appended to
set "IS_APPEND=false"
if exist "!ITEM_FILE!" (
    set "IS_APPEND=true"
)
:: Create temporary file for the new item definition
set "TEMP_ITEM=%TEMP%\temp_item_def.txt"
> "!TEMP_ITEM!" echo.
>> "!TEMP_ITEM!" echo     item !ITEM_ID!
>> "!TEMP_ITEM!" echo     {
>> "!TEMP_ITEM!" echo         DisplayName = !ITEM_NAME!,
>> "!TEMP_ITEM!" echo         Icon = !ITEM_NAME!,
>> "!TEMP_ITEM!" echo         Weight = 1.0,
>> "!TEMP_ITEM!" echo         StaticModel = "",
>> "!TEMP_ITEM!" echo         WorldStaticModel = "",
:: Loop through all parameters starting from %5 and add them as key=value pairs
set i=5
:loop
call set "PARAM=%%%i%%"
if not defined PARAM goto :close_block
>> "!TEMP_ITEM!" echo         !PARAM!,
set /a i+=1
goto loop
:close_block
>> "!TEMP_ITEM!" echo     }
:: Write start of item file or append to existing
if "%IS_APPEND%"=="true" (
    echo Appending to file: !ITEM_FILE!
    :: Check if file ends with closing brace
    for /f "usebackq delims=" %%a in (`findstr /n "^" "!ITEM_FILE!"`) do set "lastline=%%a"
    set "lastline=!lastline:*:=!"
    if not "!lastline!"=="}" (
        echo ERROR: Existing file does not end with a closing brace.
        exit /b 1
    )
    :: Create a temporary file without the closing brace
    set "TEMP_FULL=%TEMP%\temp_full_item.txt"
    type nul > "!TEMP_FULL!"
    :: Copy everything except the last line (closing brace)
    for /f "usebackq skip=1 delims=" %%a in (`findstr /n "^" "!ITEM_FILE!" ^| findstr /v /b /r ".*:}"`) do (
        set "line=%%a"
        set "line=!line:*:=!"
        echo !line! >> "!TEMP_FULL!"
    )
    :: Add the new item definition
    type "!TEMP_ITEM!" >> "!TEMP_FULL!"
    :: Add the closing brace
    echo } >> "!TEMP_FULL!"
    :: Replace the original file
    move /y "!TEMP_FULL!" "!ITEM_FILE!" > nul
) else (
    echo Creating new file: !ITEM_FILE!
    > "!ITEM_FILE!" echo module !MOD_NAME! {
    >> "!ITEM_FILE!" echo     imports {
    >> "!ITEM_FILE!" echo         Base
    >> "!ITEM_FILE!" echo     }
    :: Add the new item definition
    type "!TEMP_ITEM!" >> "!ITEM_FILE!"
    :: Close the module
    >> "!ITEM_FILE!" echo }
)
del "!TEMP_ITEM!" > nul
echo.
echo Successfully created or updated item: !ITEM_NAME!
echo File path: !ITEM_FILE!
exit /b 0