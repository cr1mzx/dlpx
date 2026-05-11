@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

set "YTDLP=%~dp0yt-dlp.exe"
set "COOKIES=%CD%\cookies.txt"
set "WAIT_TIME=10"

for /f "usebackq delims=" %%i in (`powershell -NoProfile -Command "Get-Clipboard"`) do (
    set "URL=%%i"
)

if not defined URL (
    echo Буфер обмена пуст или не содержит ссылку.
    pause
    exit /b 1
)

set "EXTRA_ARGS="
if exist "%COOKIES%" set "EXTRA_ARGS=--cookies "%COOKIES%""


"%YTDLP%" %EXTRA_ARGS% --js-runtimes node -f bestaudio --extract-audio --audio-format mp3 --audio-quality 0 --embed-metadata --embed-thumbnail --no-part "%url%"

echo Скачивание завершено успешно. Консоль закроется через %wait_time% секунд.
timeout /t %WAIT_TIME% /nobreak >nul

endlocal
exit