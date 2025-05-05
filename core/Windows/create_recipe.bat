@echo off
setlocal EnableDelayedExpansion

REM === Capture arguments ===
set "MOD_NAME=%~1"
set "RECIPE_NAME=%~2"
set "RECIPE_TYPE=%~3"
set "RESULT_ITEM=%~4"
set "RESULT_COUNT=%~5"
set "RECIPE_TIME=%~6"
set "INGREDIENTS=%~7"
set "SKILL_TYPE=%~8"
set "SKILL_LEVEL=%~9"

REM === Workaround to grab the 10th argument (MOD_PATH) ===
set "argLine=%*"
for /f "tokens=10" %%A in ("%argLine%") do set "MOD_PATH=%%~A"

REM === Remove quotes if present ===
set "MOD_PATH=%MOD_PATH:"=%"

REM === Define paths ===
set "SCRIPTS_DIR=%MOD_PATH%\media\scripts"
set "RECIPE_FILE=%SCRIPTS_DIR%\%MOD_NAME%_Recipes.txt"
set "TEMP_RECIPE=%TEMP%\temp_recipe_block.txt"
set "TEMP_FINAL=%TEMP%\temp_final_script.txt"

REM === Ensure directories exist ===
if not exist "%SCRIPTS_DIR%" (
    mkdir "%SCRIPTS_DIR%"
)

REM === Create recipe file if not exist ===
if not exist "%RECIPE_FILE%" (
    echo Creating new recipe file with module Base block...
    (
        echo module Base
        echo {
        echo }
    ) > "%RECIPE_FILE%"
)

REM === Create the recipe block in a temp file ===
(
    echo.
    echo recipe %RECIPE_NAME% {
) > "%TEMP_RECIPE%"

REM === Add ingredients ===
for %%I in ("%INGREDIENTS:,=" "%") do (
    set "item=%%~I"
    for /f "tokens=1,2 delims=:" %%a in ("!item!") do (
        if not "%%a"=="" if not "%%b"=="" (
            >> "%TEMP_RECIPE%" echo     %%b %%a,
        )
    )
)

REM === Add result, time, and category ===
>> "%TEMP_RECIPE%" echo     Result:%RESULT_ITEM%=%RESULT_COUNT%,
>> "%TEMP_RECIPE%" echo     Time:%RECIPE_TIME%,
>> "%TEMP_RECIPE%" echo     Category:%RECIPE_TYPE%,

REM === Add skill only if provided ===
set "TRIMMED_SKILL=%SKILL_TYPE: =%"
if defined TRIMMED_SKILL (
    >> "%TEMP_RECIPE%" echo     SkillRequired:%SKILL_TYPE%=%SKILL_LEVEL%,
)

REM === Close recipe block ===
>> "%TEMP_RECIPE%" echo }

REM === Insert recipe into the file, just before the final '}' ===
set "insertion_done=0"
(for /f "usebackq delims=" %%a in ("%RECIPE_FILE%") do (
    set "line=%%a"
    if "!line!" == "}" (
        if "!insertion_done!" == "0" (
            type "%TEMP_RECIPE%" >> "%TEMP_FINAL%"
            set "insertion_done=1"
        )
    )
    >> "%TEMP_FINAL%" echo(!line!
))

REM === Overwrite original file ===
move /y "%TEMP_FINAL%" "%RECIPE_FILE%" >nul
del "%TEMP_RECIPE%" >nul

echo Successfully added recipe "%RECIPE_NAME%" to "%RECIPE_FILE%"
exit /b 0
