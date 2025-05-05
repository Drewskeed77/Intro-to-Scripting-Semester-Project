@echo off
setlocal enabledelayedexpansion

:: Usage: install_mod.bat <mod_name> <mod_path>

:: Check arguments
if "%~2"=="" (
    echo Error: Missing arguments
    echo Usage: install_mod.bat ^<mod_name^> ^<mod_path^>
    exit /b 1
)

:: Set variables
set "MOD_NAME=%~1"
set "MOD_PATH=%~2"

:: Remove trailing slash or backslash
if "!MOD_PATH:~-1!"=="\" set "MOD_PATH=!MOD_PATH:~0,-1!"
if "!MOD_PATH:~-1!"=="/" set "MOD_PATH=!MOD_PATH:~0,-1!"

:: Display status
echo Installing mod: "!MOD_NAME!"
echo From path: "!MOD_PATH!"

:: Check source directory exists
if not exist "!MOD_PATH!" (
    echo ERROR: Mod path does not exist: "!MOD_PATH!"
    exit /b 1
)

:: Set Project Zomboid mods folder
set "PZ_MODS_DIR=%USERPROFILE%\Zomboid\mods"

:: Ensure mods folder exists
if not exist "!PZ_MODS_DIR!" (
    echo Creating mods directory: "!PZ_MODS_DIR!"
    mkdir "!PZ_MODS_DIR!"
)

:: Set destination directory
set "TARGET_DIR=!PZ_MODS_DIR!\!MOD_NAME!"
echo Installing to: "!TARGET_DIR!"

:: Use robocopy to copy mod files
robocopy "!MOD_PATH!" "!TARGET_DIR!" /E /NFL /NDL /NJH /NJS /NP >nul

:: Check robocopy exit code
set "ROBOCODE=%ERRORLEVEL%"
if !ROBOCODE! GEQ 8 (
    echo ERROR: Robocopy failed with exit code !ROBOCODE!
    exit /b 1
)

echo Successfully installed "!MOD_NAME!" to Project Zomboid mods folder
echo Files copied from: "!MOD_PATH!"
echo Mod installed to: "!TARGET_DIR!"

endlocal
exit /b 0
