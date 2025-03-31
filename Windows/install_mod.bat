@echo off
:: install_mod.bat - Improved version
:: Usage: install_mod.bat <mod_name> <mod_path>

setlocal enabledelayedexpansion

:: Check for correct number of arguments
if "%~2"=="" (
    echo Error: Missing arguments
    echo Usage: install_mod.bat ^<mod_name^> ^<mod_path^>
    exit /b 1
)

set MOD_NAME=%~1
set MOD_PATH=%~2

:: Remove trailing slash if present
if "!MOD_PATH:~-1!"=="\" set MOD_PATH=!MOD_PATH:~0,-1!
if "!MOD_PATH:~-1!"=="/" set MOD_PATH=!MOD_PATH:~0,-1!

echo Installing mod: %MOD_NAME%
echo Mod path: %MOD_PATH%

:: Verify mod path exists
if not exist "%MOD_PATH%" (
    echo ERROR: Mod path does not exist: %MOD_PATH%
    exit /b 1
)

:: Determine destination path (mods folder in Project Zomboid)
set PZ_MODS_DIR=%USERPROFILE%\Zomboid\mods
if not exist "%PZ_MODS_DIR%" (
    echo Creating mods directory: %PZ_MODS_DIR%
    mkdir "%PZ_MODS_DIR%"
)

:: Create mod-specific directory
set TARGET_DIR=%PZ_MODS_DIR%\%MOD_NAME%
echo Installing to: %TARGET_DIR%

:: Copy files (robocopy is more reliable than xcopy)
robocopy "%MOD_PATH%" "%TARGET_DIR%" /E /NFL /NDL /NJH /NJS /NP

if errorlevel 8 (
    echo ERROR: Failed to copy mod files
    exit /b 1
)

echo Successfully installed %MOD_NAME% to Project Zomboid mods folder
echo Mod files copied from: %MOD_PATH%
echo Mod installed to: %TARGET_DIR%

endlocal
exit /b 0