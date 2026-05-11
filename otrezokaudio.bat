@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

set "YTDLP=%~dp0yt-dlp.exe"
set "COOKIES=%CD%\cookies.txt"
set "WAIT_TIME=10"

for /f "usebackq delims=" %%i in (`powershell -NoProfile -Command "Get-Clipboard"`) do (
    set "URL=%%i"
)

if "%URL%"=="" (
    echo Буфер обмена пуст или не содержит ссылку.
    pause
    exit
)

set /p start_time=Введите время начала: 
set /p end_time=Введите время конца: 

set "EXTRA_ARGS="
if exist "%COOKIES%" (
    set "EXTRA_ARGS=--cookies "%COOKIES%""
)

"%YTDLP%" "!URL!" --js-runtimes node --download-sections "*%start_time%-%end_time%" -f bestaudio --extract-audio --audio-format mp3 --embed-metadata --embed-thumbnail

echo Скачивание завершено. Консоль закроется через %WAIT_TIME% секунд.
timeout /t %WAIT_TIME% /nobreak >nul

endlocal
exit