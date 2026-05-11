@echo off
chcp 65001 >nul

:: --- Права администратора ---
net session >nul 2>&1
if %errorlevel% neq 0 (
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit
)

:: --- Запуск в Windows Terminal ---
if not defined WT_SESSION (
    where wt >nul 2>&1 && (
        wt -w 0 nt cmd /k "%~f0"
        exit
    )
)

set "BASE=%~dp0"
set "BASE=%BASE:~0,-1%"

reg query "HKCR\Directory\Background\shell\Скачать" >nul 2>&1
if %errorlevel%==0 (goto menu) else (goto install_menu)

:install_menu
cls
echo.
echo  ╔══════════════════════════════════════╗
echo  ║            Установка dlpx            ║
echo  ╚══════════════════════════════════════╝
echo.
echo  Выберите цвет значков:
echo.
echo   1 - Черные
echo   2 - Белые
echo.
echo  GitHub: https://github.com/cr1mzx/dlpx
echo  ----------------------------------------

set "choice="
set /p "choice=> "
if not defined choice goto install_menu

if /i "%choice%"=="1" set "ICON_SUFFIX=_black"
if /i "%choice%"=="2" set "ICON_SUFFIX=_white"
if not defined ICON_SUFFIX goto install_menu

goto install

:menu
cls

for /f "tokens=2*" %%a in ('reg query "HKCR\Directory\Background\shell\Скачать" /v icon 2^>nul') do set ICON_PATH=%%b

echo.
echo  ╔══════════════════════════════════════╗
echo  ║          ✅ dlpx установлен          ║
echo  ╚══════════════════════════════════════╝
echo.

echo %ICON_PATH% | find "_black.ico" >nul
if %errorlevel%==0 (
    set "CURRENT=⚫️ Черный"
    set "ALT=⚪️ Белый"
    set "ALT_SUFFIX=_white"
) else (
    set "CURRENT=⚪️ Белый"
    set "ALT=⚫️ Черный"
    set "ALT_SUFFIX=_black"
)

echo  Текущий цвет значков: %CURRENT%
echo.
echo   1 - Изменить цвет значков на %ALT%
echo   2 - Проверить обновления yt-dlp
echo.
echo   3 - Удалить
echo.
echo  GitHub: https://github.com/cr1mzx/dlpx
echo  --------------------------------------

set "choice="
set /p "choice=> "
if not defined choice goto menu

if /i "%choice%"=="1" (
    set "ICON_SUFFIX=%ALT_SUFFIX%"
    goto install
)

if /i "%choice%"=="2" goto update

if /i "%choice%"=="3" (
    reg delete "HKCR\Directory\Background\shell\Скачать" /f
	goto install_menu
)

goto menu

:install

reg add "HKCR\Directory\Background\shell\Скачать" /v icon /t REG_SZ /d "%BASE%\icons\download%ICON_SUFFIX%.ico" /f
reg add "HKCR\Directory\Background\shell\Скачать" /v subcommands /t REG_SZ /d "" /f

reg add "HKCR\Directory\Background\shell\Скачать\shell\Видео" /v icon /t REG_SZ /d "%BASE%\icons\video%ICON_SUFFIX%.ico" /f
reg add "HKCR\Directory\Background\shell\Скачать\shell\Видео\command" /ve /t REG_SZ /d "\"%BASE%\savevideo.bat\"" /f

reg add "HKCR\Directory\Background\shell\Скачать\shell\Аудио" /v icon /t REG_SZ /d "%BASE%\icons\music%ICON_SUFFIX%.ico" /f
reg add "HKCR\Directory\Background\shell\Скачать\shell\Аудио\command" /ve /t REG_SZ /d "\"%BASE%\saveaudio.bat\"" /f

reg add "HKCR\Directory\Background\shell\Скачать\shell\Без Рекламы" /v icon /t REG_SZ /d "%BASE%\icons\noads%ICON_SUFFIX%.ico" /f
reg add "HKCR\Directory\Background\shell\Скачать\shell\Без Рекламы\command" /ve /t REG_SZ /d "\"%BASE%\savevideonoadd.bat\"" /f

reg add "HKCR\Directory\Background\shell\Скачать\shell\Превью" /v icon /t REG_SZ /d "%BASE%\icons\preview%ICON_SUFFIX%.ico" /f
reg add "HKCR\Directory\Background\shell\Скачать\shell\Превью\command" /ve /t REG_SZ /d "\"%BASE%\preview.bat\"" /f

reg add "HKCR\Directory\Background\shell\Скачать\shell\Отрывок" /v icon /t REG_SZ /d "%BASE%\icons\otrezok%ICON_SUFFIX%.ico" /f
reg add "HKCR\Directory\Background\shell\Скачать\shell\Отрывок" /v subcommands /t REG_SZ /d "" /f

reg add "HKCR\Directory\Background\shell\Скачать\shell\Отрывок\shell\Видео" /v icon /t REG_SZ /d "%BASE%\icons\video%ICON_SUFFIX%.ico" /f
reg add "HKCR\Directory\Background\shell\Скачать\shell\Отрывок\shell\Видео\command" /ve /t REG_SZ /d "\"%BASE%\otrezok.bat\"" /f

reg add "HKCR\Directory\Background\shell\Скачать\shell\Отрывок\shell\Аудио" /v icon /t REG_SZ /d "%BASE%\icons\music%ICON_SUFFIX%.ico" /f
reg add "HKCR\Directory\Background\shell\Скачать\shell\Отрывок\shell\Аудио\command" /ve /t REG_SZ /d "\"%BASE%\otrezokaudio.bat\"" /f

goto menu

:update
cls
echo.

set "BASEDIR=%BASE%"
set "EXE=%BASEDIR%\yt-dlp.exe"
set "OLDDIR=%BASEDIR%\old"

if not exist "%OLDDIR%" mkdir "%OLDDIR%"

powershell -NoProfile -ExecutionPolicy Bypass ^
  "$apiUrl = 'https://api.github.com/repos/yt-dlp/yt-dlp/releases/latest';" ^
  "$release = Invoke-RestMethod -Uri $apiUrl -Headers @{ 'User-Agent' = 'Mozilla/5.0' };" ^
  "$asset = $release.assets | Where-Object { $_.name -eq 'yt-dlp.exe' };" ^
  "$newVersion = $release.tag_name;" ^
  "Write-Host 'Последний релиз:' $newVersion;" ^
  "if (Test-Path '%EXE%') {" ^
  "  $localVersion = (& '%EXE%' --version);" ^
  "  Write-Host 'Локальная версия:' $localVersion;" ^
  "  if ($localVersion -eq $newVersion) { Write-Host 'yt-dlp уже обновлён!' -ForegroundColor Green; exit };" ^
  "  $timestamp = Get-Date -Format 'yyyyMMdd_HHmmss';" ^
  "  Move-Item '%EXE%' (Join-Path '%OLDDIR%' ('yt-dlp_' + $localVersion + '_' + $timestamp + '.exe'));" ^
  "};" ^
  "Write-Host 'Скачивание новой версии...';" ^
  "Invoke-WebRequest -Uri $asset.browser_download_url -OutFile '%EXE%';" ^
  "Write-Host 'Обновление завершено до версии' $newVersion;"

pause
goto menu