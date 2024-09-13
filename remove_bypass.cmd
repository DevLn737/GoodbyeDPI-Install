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
echo        Starting DPIBypass Uninstallation
echo ============================================
echo.

:: Путь к папке DPIBypass в AppData
set "BYPASS_FOLDER=%LOCALAPPDATA%\DPIByPass"

echo [1/5] Stopping DPIBypass service if it is running...
:: Остановка службы DPIBypass, если она запущена
sc stop DPIBypass
echo.

echo [2/5] Deleting DPIBypass service...
:: Удаление службы DPIBypass
sc delete DPIBypass
echo Deleted DPIBypass service.
echo.

echo [3/5] Unloading WinDivert driver if it is loaded...
:: Выгрузка драйвера WinDivert
sc stop "WinDivert"
sc delete "WinDivert"
echo.

echo [4/5] Deleting downloaded files and folders...
:: Удаление всех файлов и папок DPIBypass
if exist "%BYPASS_FOLDER%" (
    rd /s /q "%BYPASS_FOLDER%"
    echo Deleted %BYPASS_FOLDER%.
) else (
    echo DPIBypass folder does not exist.
)
echo.

if not exist "%BYPASS_FOLDER%" (
    echo DPIBypass folder successfully removed.
) else (
    echo Failed to remove DPIBypass folder.
)
echo.

echo ============================================
echo        DPIBypass Uninstallation Completed
echo ============================================
echo.

echo [5/5] After remove is complete, it is strongly recommended to reboot your PC.
pause
endlocal