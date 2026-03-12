@echo off
pushd "%~dp0"
setlocal enabledelayedexpansion

echo.
echo Select resize mode:
echo 1. Width
echo 2. Height
choice /c 12 /n /m "Resize based on width or height? [1/2]: "

if errorlevel 2 (
    set "mode=height"
) else (
    set "mode=width"
)

echo.
set /p "dimension=Enter the !mode! in pixels: "
if not defined dimension (
    echo No value entered. Exiting.
    goto :done
)

echo(!dimension!| findstr /r "^[1-9][0-9]*$" >nul
if errorlevel 1 (
    echo Invalid size "!dimension!". Enter a whole number greater than 0.
    goto :done
)

echo.
set "targetFormat="
set /p "targetFormat=Enter output format (mp4, mov, mkv, avi, webm) or press Enter to keep original: "
if defined targetFormat (
    if "!targetFormat:~0,1!"=="." set "targetFormat=!targetFormat:~1!"
    if /i not "!targetFormat!"=="mp4" if /i not "!targetFormat!"=="mov" if /i not "!targetFormat!"=="mkv" if /i not "!targetFormat!"=="avi" if /i not "!targetFormat!"=="webm" (
        echo Invalid format "!targetFormat!". Allowed values: mp4, mov, mkv, avi, webm.
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
        echo Processing "%%f"...
        ffmpeg -i "%%f" -c:v libx264 -preset fast -crf 28 -bufsize 2M -c:a aac -b:a 128k -movflags +faststart -vf "!scaleFilter!" "!outputDir!\!filename!!outExt!"
    )
)

if !count! EQU 0 (
    echo No video files found in this folder.
) else (
    echo.
    echo Done! Converted !count! video(s).
    echo Output folder: "!outputDir!"
)

:done
popd
pause
