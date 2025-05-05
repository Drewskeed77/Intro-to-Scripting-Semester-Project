@echo off
setlocal EnableDelayedExpansion
:: === Core arguments ===
set "MOD_NAME=%~1"
set "SOUND_TYPE=%~2"
set "SOUND_NAME=%~3"
set "MOD_PATH=%~4"
:: Paths
set "SCRIPTS_DIR=%MOD_PATH%\media\scripts"
set "SOUND_FILE=%SCRIPTS_DIR%\sounds_%SOUND_TYPE%.txt"
if not exist "%SCRIPTS_DIR%" mkdir "%SCRIPTS_DIR%"
:: Check if file exists
set "IS_APPEND=false"
if exist "%SOUND_FILE%" (
    set "IS_APPEND=true"
)
:: Create temporary file for the sound definition
set "TEMP_FILE=%TEMP%\temp_sound_block.txt"
(
    echo.
    echo     sound %SOUND_NAME% {
    echo         category = Player,
    echo         loop = true,
    echo         is3D = true,
    echo         clip {
    echo         file = media/sound/%SOUND_NAME%.ogg,
    echo         distanceMax = 6,
    echo         reverbFactor = 0.1,
    echo         volume = 0.7,
    echo                  }
) > "%TEMP_FILE%"
:: === Parse key=value pairs ===
shift
shift
shift
shift
:loop
if "%~1"=="" goto insert_block
for /f "tokens=1,2 delims==" %%a in ("%~1") do (
    if not "%%a"=="" if not "%%b"=="" (
        :: Check if it's a clip property
        echo "%%a" | findstr /i "distanceMax reverbFactor volume file" > nul
        if !errorlevel! equ 0 (
            :: It's a clip property, indented more
            for /f "usebackq delims=" %%i in ("%TEMP_FILE%") do (
                set "line=%%i"
                echo !line! | findstr /c:"%%a" > nul
                if !errorlevel! equ 0 (
                    :: Replace the line
                    findstr /v /c:"%%a" "%TEMP_FILE%" > "%TEMP_FILE%.new"
                    echo         %%a = %%b, >> "%TEMP_FILE%.new"
                    move /y "%TEMP_FILE%.new" "%TEMP_FILE%" > nul
                )
            )
        ) else (
            :: It's a regular sound property
            echo         %%a = %%b, >> "%TEMP_FILE%"
        )
    )
)
shift
goto loop
:insert_block
>> "%TEMP_FILE%" echo     }
:: Insert sound block into the file
if "%IS_APPEND%"=="true" (
    echo Appending to file: %SOUND_FILE%
    :: Check if file ends with closing brace
    for /f "usebackq delims=" %%a in (`findstr /n "^" "%SOUND_FILE%"`) do set "lastline=%%a"
    set "lastline=!lastline:*:=!"
    if not "!lastline!"=="}" (
        echo ERROR: Existing file does not end with a closing brace.
        exit /b 1
    )
    :: Create a temporary file without the closing brace
    set "TEMP_FULL=%TEMP%\temp_full_sound.txt"
    type nul > "%TEMP_FULL%"
    :: Copy everything except the last line (closing brace)
    for /f "usebackq skip=1 delims=" %%a in (`findstr /n "^" "%SOUND_FILE%" ^| findstr /v /b /r ".*:}"`) do (
        set "line=%%a"
        set "line=!line:*:=!"
        echo !line! >> "%TEMP_FULL%"
    )
    :: Add the sound block
    type "%TEMP_FILE%" >> "%TEMP_FULL%"
    :: Add the closing brace
    echo } >> "%TEMP_FULL%"
    :: Replace the original file
    move /y "%TEMP_FULL%" "%SOUND_FILE%" > nul
) else (
    echo Creating new file: %SOUND_FILE%
    :: Create file with module header
    > "%SOUND_FILE%" echo module %MOD_NAME% {
    :: Add the sound block
    type "%TEMP_FILE%" >> "%SOUND_FILE%"
    :: Add the closing brace
    echo } >> "%SOUND_FILE%"
)
del "%TEMP_FILE%" > nul
echo Successfully created or updated sound: %SOUND_NAME%
echo File path: %SOUND_FILE%
exit /b 0