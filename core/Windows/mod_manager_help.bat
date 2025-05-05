@echo off
setlocal enabledelayedexpansion
:: Help Menu
:help
echo Project Zomboid Mod Manager
echo ----------------------------
echo Commands:
echo   create      - Create a new mod
echo   register    - Register an existing mod from somewhere else into the registry
echo   flush       - Deletes all mods within the registry
echo   item        - Create a new item for a mod
echo   recipe      - Create a new recipe for a mod
echo   model       - Create a new model for a mod
echo   sound       - Create a new sound for a mod
echo   list        - List all registered mods
echo   install     - Install a registered mod
echo   delete      - Remove a mod from registry
echo   validate    - Check all mod paths
echo   exit        - Quit the program
echo   help        - Show this help message
echo.

pause
exit /b
