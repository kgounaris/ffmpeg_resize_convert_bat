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

echo.
echo %ACCENT%Select video codec:%RESET%
echo %ACCENT%1. H.264 (libx264)   - universal compatibility%RESET%
echo %ACCENT%2. H.265 (libx265)   - smaller files, HEVC%RESET%
echo %ACCENT%3. VP9   (libvpx-vp9)- web, needs webm/mkv%RESET%
echo %ACCENT%4. AV1   (libsvtav1) - smallest, very slow encode%RESET%
choice /c 1234 /n /m "%ACCENT%Choose codec [1/2/3/4]: %RESET%"
if errorlevel 4 (
    set "codec=av1"
) else if errorlevel 3 (
    set "codec=vp9"
) else if errorlevel 2 (
    set "codec=h265"
) else (
    set "codec=h264"
)

echo.
echo %ACCENT%Select quality:%RESET%
echo %ACCENT%1. High quality  (larger files)%RESET%
echo %ACCENT%2. Balanced      (recommended)%RESET%
echo %ACCENT%3. Smaller size%RESET%
choice /c 123 /n /m "%ACCENT%Choose quality [1/2/3]: %RESET%"
if errorlevel 3 (
    set "qlevel=3"
) else if errorlevel 2 (
    set "qlevel=2"
) else (
    set "qlevel=1"
)

rem The AV1 encoder depends on the FFmpeg build: prefer SVT-AV1, else libaom.
set "av1Enc=-c:v libaom-av1 -b:v 0 -cpu-used 6 -row-mt 1"
ffmpeg -hide_banner -encoders 2>nul | findstr /i "libsvtav1" >nul
if not errorlevel 1 set "av1Enc=-c:v libsvtav1 -preset 8"

rem Per-codec encoder flags, CRF-per-quality, and allowed containers.
rem CRF scales differ per codec, so each maps the quality level to its own value.
if /i "!codec!"=="h264" (
    set "vEnc=-c:v libx264 -preset fast"
    set "defContainer=mp4"
    set "allowed= mp4 mov mkv avi "
    if "!qlevel!"=="1" set "crf=20"
    if "!qlevel!"=="2" set "crf=23"
    if "!qlevel!"=="3" set "crf=28"
) else if /i "!codec!"=="h265" (
    set "vEnc=-c:v libx265 -preset fast"
    set "defContainer=mp4"
    set "allowed= mp4 mov mkv "
    if "!qlevel!"=="1" set "crf=24"
    if "!qlevel!"=="2" set "crf=28"
    if "!qlevel!"=="3" set "crf=32"
) else if /i "!codec!"=="vp9" (
    set "vEnc=-c:v libvpx-vp9 -b:v 0 -deadline good -cpu-used 2 -row-mt 1"
    set "defContainer=webm"
    set "allowed= webm mkv "
    if "!qlevel!"=="1" set "crf=31"
    if "!qlevel!"=="2" set "crf=33"
    if "!qlevel!"=="3" set "crf=36"
) else (
    set "vEnc=!av1Enc!"
    set "defContainer=mkv"
    set "allowed= mkv mp4 webm "
    if "!qlevel!"=="1" set "crf=25"
    if "!qlevel!"=="2" set "crf=30"
    if "!qlevel!"=="3" set "crf=35"
)

echo.
echo %DIM%Using codec !codec! at CRF !crf!.%RESET%

if /i "!mode!"=="width" (
    set "scaleFilter=scale=!dimension!:-2"
) else (
    set "scaleFilter=scale=-2:!dimension!"
)

if not exist "exports" mkdir "exports"
set "outputDir=exports\!mode!_!dimension!_!codec!_crf!crf!"
if not exist "!outputDir!" mkdir "!outputDir!"

set /a count=0
for %%f in (*.mp4 *.mov *.mkv *.avi *.wmv *.flv *.webm *.m4v *.mpg *.mpeg *.ts) do (
    if exist "%%f" (
        set /a count+=1
        set "filename=%%~nf"

        rem Decide the output extension: chosen format, else the original.
        if defined targetFormat (
            set "ext=!targetFormat!"
        ) else (
            set "ext=%%~xf"
            set "ext=!ext:~1!"
        )

        rem Force a container the chosen codec can actually write.
        echo !allowed!| findstr /i /c:" !ext! " >nul
        if errorlevel 1 (
            echo %ACCENT%  Note: .!ext! is not compatible with !codec!; using .!defContainer! instead.%RESET%
            set "ext=!defContainer!"
        )

        rem WebM needs Opus audio; every other container uses AAC.
        if /i "!ext!"=="webm" (
            set "aEnc=-c:a libopus -b:a 128k"
        ) else (
            set "aEnc=-c:a aac -b:a 128k"
        )

        rem Faststart only matters for MP4/MOV; add Apple HEVC tag for H.265 there.
        set "extra="
        if /i "!ext!"=="mp4" set "extra=-movflags +faststart"
        if /i "!ext!"=="mov" set "extra=-movflags +faststart"
        if /i "!codec!"=="h265" if /i "!ext!"=="mp4" set "extra=!extra! -tag:v hvc1"
        if /i "!codec!"=="h265" if /i "!ext!"=="mov" set "extra=!extra! -tag:v hvc1"

        echo %DIM%Processing "%%f" -^> !filename!.!ext!...%RESET%
        ffmpeg -i "%%f" !vEnc! -crf !crf! !extra! -vf "!scaleFilter!" !aEnc! "!outputDir!\!filename!.!ext!"
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
