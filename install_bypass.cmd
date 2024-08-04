@echo off
setlocal

:: Проверка прав администратора
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo This script requires administrative privileges.
    echo Please run this script as an administrator.
    pause
    exit /b 1
)

echo ============================================
echo        Starting DPIBypass Setup
echo ============================================
echo.

:: Путь к папке DPIBypass в AppData
set "BYPASS_FOLDER=%LOCALAPPDATA%\DPIByPass"

:: URL для скачивания GoodbyeDPI
set "GOODBYE_DPI_URL=https://github.com/ValdikSS/GoodbyeDPI/releases/download/0.2.3rc1/goodbyedpi-0.2.3rc1-2.zip"

:: Имя файла архива
set "ZIP_FILE_NAME=goodbyedpi-0.2.3rc1-2.zip"

:: URL для скачивания списка доменов YouTube
set "YT_DOMAINS_URL=https://raw.githubusercontent.com/DevLn737/GoodbyeDPI-Install/main/russia-youtube.txt"

echo [1/8] Checking if DPIBypass folder exists...
:: Проверка наличия папки, создание при необходимости
if not exist "%BYPASS_FOLDER%" (
    mkdir "%BYPASS_FOLDER%"
    echo Created DPIBypass folder at %BYPASS_FOLDER%
) else (
    echo DPIBypass folder already exists.
)
echo.

:: Переход в папку BYPASS_FOLDER
pushd "%BYPASS_FOLDER%"

echo [2/8] Downloading GoodbyeDPI...
:: Скачивание архива GoodbyeDPI
powershell -Command "Invoke-WebRequest -Uri '%GOODBYE_DPI_URL%' -OutFile '%ZIP_FILE_NAME%'"
echo Downloaded GoodbyeDPI to %BYPASS_FOLDER%\%ZIP_FILE_NAME%
echo.

echo [3/8] Extracting GoodbyeDPI archive...
:: Распаковка архива
powershell -Command "Expand-Archive -Path '%ZIP_FILE_NAME%' -DestinationPath '%BYPASS_FOLDER%' -Force"
echo Extracted GoodbyeDPI.
echo.

echo [4/8] Cleaning up downloaded archive...
:: Удаление архива
del "%ZIP_FILE_NAME%"
echo Deleted %ZIP_FILE_NAME%.
echo.

:: Переход в распакованную папку x86_64
pushd "%BYPASS_FOLDER%\goodbyedpi-0.2.3rc1\x86_64"

echo [5/8] Downloading YouTube domains list...
:: Скачивание списка доменов YouTube
powershell -Command "Invoke-WebRequest -Uri '%YT_DOMAINS_URL%' -OutFile 'russia-youtube.txt'"
echo Downloaded YouTube domains list.
echo.

echo [6/8] Creating DPIBypass service...
:: Создание службы DPIBypass
sc create DPIBypass binPath= "\"%BYPASS_FOLDER%\goodbyedpi-0.2.3rc1\x86_64\goodbyedpi.exe\" --auto-ttl -6 --native-frag --blacklist \"%BYPASS_FOLDER%\goodbyedpi-0.2.3rc1\x86_64\russia-youtube.txt\"" start= auto
sc description DPIBypass "Passive bypass of deep packet analysis by the provider"
echo Created DPIBypass service.
echo.

echo [7/8] Starting DPIBypass service...
:: Запуск службы DPIBypass
sc start DPIBypass
echo Started DPIBypass service.
echo.


popd
popd

endlocal
echo ============================================
echo        DPIBypass Setup Completed
echo ============================================
echo.
echo [8/8] After setup is complete, it is strongly recommended to reboot your PC.
pause