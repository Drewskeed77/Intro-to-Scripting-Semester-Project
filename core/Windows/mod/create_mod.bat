@echo off
setlocal enabledelayedexpansion

:: Check arguments
if "%~2"=="" (
    echo Usage: create_mod.bat ^<mod_name^> ^<mod_path^> ^<optional_folder_names^>
    echo Example: create_mod.bat MyMod "C:\MyMods" anims animscript AnimSets
    exit /b 1
)

set "MOD_NAME=%~1"
set "MOD_PATH=%~2"

:: Create mod base directory
set "FULL_MOD_PATH=%MOD_PATH%\%MOD_NAME%"
mkdir "!FULL_MOD_PATH!"
cd /d "!FULL_MOD_PATH!"

:: Create media folder
mkdir media

:: Write mod.info contents
(
    echo name=%MOD_NAME%
    echo id=%MOD_NAME%
    echo description=A new Project Zomboid mod called %MOD_NAME%.
    echo poster=poster.png
    echo url=https://theindiestone.com/forums/
) > mod.info

:: Create placeholder poster
echo [Placeholder image file] > poster.png

:: Go into media folder to create subfolders
cd media

:: Shift to additional folder arguments
shift /2

:LOOP
if "%~1"=="" goto END

mkdir "%~1"
shift /1
goto LOOP

:END
echo Mod %MOD_NAME% created successfully at %FULL_MOD_PATH%.
