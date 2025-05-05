@echo off
setlocal enabledelayedexpansion
:: Arguments
set "mod_name=%1"
set "mod_path=%2"
set "model_name=%3"

:: Config file path
set "config_file=%mod_path%\media\scripts\models.txt"

:: Make sure directories exist
if not exist "%mod_path%\media\scripts" (
    echo Creating directory structure...
    mkdir "%mod_path%\media\scripts" 2>nul
)

:: If file doesn't exist, create with module header
if not exist "%config_file%" (
    echo Creating new config file with module header...
    (
        echo module Base
        echo {
        echo }
    ) > "%config_file%"
)

:: Model block to insert
(
    echo.
    echo    model %model_name%
    echo    {
    echo        mesh = WorldItems/%model_name%,
    echo        texture = WorldItems/%model_name%,
    echo        scale = 1,
    echo    }
) > temp_model_block.txt

:: Prepare temporary output file
set "temp_file=%mod_path%\media\scripts\models_temp.txt"
set "insertion_done=0"

:: Read and rewrite original file, insert model before final }
(for /f "usebackq delims=" %%a in ("%config_file%") do (
    set "line=%%a"
    if "!line!" == "}" (
        if "!insertion_done!" == "0" (
            type temp_model_block.txt >> "%temp_file%"
            set "insertion_done=1"
        )
    )
    >> "%temp_file%" echo(!line!
))

:: Replace original file
move /y "%temp_file%" "%config_file%" >nul
del temp_model_block.txt

::Check if the file exists after operations
if exist "%config_file%" (
    echo Model '%model_name%' added to '%config_file%'
    exit /b 0
) else (
    echo ERROR: Failed to create or update '%config_file%'
    echo MOD_PATH is set to: %mod_path%
    echo Full config path: %config_file%
    exit /b 1
)