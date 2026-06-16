@echo off
pushd "%~dp0"
setlocal enabledelayedexpansion

rem === Branding / terminal setup =========================================
title FFmpeg Batch Resizer

rem Capture the ESC character so ANSI/VT color codes work on Win10/11.
for /F %%a in ('echo prompt $E ^| cmd') do set "ESC=%%a"

rem Color palette (always paired with %RESET% so colors never bleed).
set "TITLE=%ESC%[96m"
set "ACCENT=%ESC%[93m"
set "OK=%ESC%[92m"
set "ERR=%ESC%[91m"
set "HILITE=%ESC%[95m"
set "DIM=%ESC%[36m"
set "RESET=%ESC%[0m"

cls
echo %TITLE%
echo  _____  _____  __  __  ____   _____   ____
echo ^|  ___^|^|  ___^|^|  \/  ^|^|  _ \ ^| ____^| / ___^|
echo ^| ^|_   ^| ^|_   ^| ^|\/^| ^|^| ^|_) ^|^|  _^|  ^| ^|  _
echo ^|  _^|  ^|  _^|  ^| ^|  ^| ^|^|  __/ ^| ^|___ ^| ^|_^| ^|
echo ^|_^|    ^|_^|    ^|_^|  ^|_^|^|_^|    ^|_____^| \____^|
echo.
echo            B A T C H   R E S I Z E R
echo  ============================================
echo %RESET%

rem Fail fast with a red line if FFmpeg is not on PATH.
where ffmpeg >nul 2>&1
if errorlevel 1 (
    echo %ERR%FFmpeg was not found in your PATH. Install it and try again.%RESET%
    goto :done
)
rem ======================================================================

echo.
echo %ACCENT%Select resize mode:%RESET%
echo %ACCENT%1. Width%RESET%
echo %ACCENT%2. Height%RESET%
choice /c 12 /n /m "%ACCENT%Resize based on width or height? [1/2]: %RESET%"

if errorlevel 2 (
    set "mode=height"
) else (
    set "mode=width"
)

echo.
set /p "dimension=%ACCENT%Enter the !mode! in pixels: %RESET%"
if not defined dimension (
    echo %ERR%No value entered. Exiting.%RESET%
    goto :done
)

echo(!dimension!| findstr /r "^[1-9][0-9]*$" >nul
if errorlevel 1 (
    echo %ERR%Invalid size "!dimension!". Enter a whole number greater than 0.%RESET%
    goto :done
)

echo.
set "targetFormat="
set /p "targetFormat=%ACCENT%Enter output format (mp4, mov, mkv, avi, webm) or press Enter to keep original: %RESET%"
if defined targetFormat (
    if "!targetFormat:~0,1!"=="." set "targetFormat=!targetFormat:~1!"
    if /i not "!targetFormat!"=="mp4" if /i not "!targetFormat!"=="mov" if /i not "!targetFormat!"=="mkv" if /i not "!targetFormat!"=="avi" if /i not "!targetFormat!"=="webm" (
        echo %ERR%Invalid format "!targetFormat!". Allowed values: mp4, mov, mkv, avi, webm.%RESET%
        goto :done
    )
)

if /i "!mode!"=="width" (
    set "scaleFilter=scale=!dimension!:-2"
) else (
    set "scaleFilter=scale=-2:!dimension!"
)

set "outputDir=!mode!_!dimension!"
if not exist "!outputDir!" mkdir "!outputDir!"

set /a count=0
for %%f in (*.mp4 *.mov *.mkv *.avi *.wmv *.flv *.webm *.m4v *.mpg *.mpeg *.ts) do (
    if exist "%%f" (
        set /a count+=1
        set "filename=%%~nf"
        if defined targetFormat (
            set "outExt=.!targetFormat!"
        ) else (
            set "outExt=%%~xf"
        )
        echo %DIM%Processing "%%f"...%RESET%
        ffmpeg -i "%%f" -c:v libx264 -preset fast -crf 28 -bufsize 2M -c:a aac -b:a 128k -movflags +faststart -vf "!scaleFilter!" "!outputDir!\!filename!!outExt!"
        if errorlevel 1 (
            echo %ERR%  [FAILED] %%f%RESET%
        ) else (
            echo %OK%  [DONE]   %%f%RESET%
        )
    )
)

if !count! EQU 0 (
    echo %ERR%No video files found in this folder.%RESET%
) else (
    echo.
    echo %HILITE%============================================%RESET%
    echo %HILITE%Done! Converted !count! video(s).%RESET%
    echo %HILITE%Output folder: "!outputDir!"%RESET%
    echo %HILITE%============================================%RESET%
)

:done
echo %RESET%
popd
pause
