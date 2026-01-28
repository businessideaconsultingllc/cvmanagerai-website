@echo off
setlocal enabledelayedexpansion

echo =======================================================
echo CV Manager AI - Android APK Deployment Script
echo =======================================================
echo.

REM Extract version from pubspec.yaml
set "APP_VERSION=Unknown"
for /f "tokens=2" %%a in ('findstr "^version:" pubspec.yaml') do set APP_VERSION=%%a
echo Detected App Version: %APP_VERSION%
echo.

echo 1. getting dependencies...
call flutter pub get

echo 2. Building Release APK...
echo This may take a few minutes...
call flutter build apk --release
if %errorlevel% neq 0 (
    echo [ERROR] Build failed!
    pause
    exit /b %errorlevel%
)
echo [SUCCESS] Build completed.
echo.

set OUTPUT_DIR=release_builds
if not exist %OUTPUT_DIR% mkdir %OUTPUT_DIR%

echo 3. Copying APK to %OUTPUT_DIR%...
set SOURCE_APK=build\app\outputs\flutter-apk\app-release.apk
set TARGET_APK=%OUTPUT_DIR%\CV_Manager_AI_v%APP_VERSION%.apk

copy /Y "%SOURCE_APK%" "%TARGET_APK%" >nul
if %errorlevel% neq 0 (
    echo [ERROR] Failed to copy APK.
    pause
    exit /b %errorlevel%
)

echo.
echo [SUCCESS] APK Deployment completed!
echo File located at: %TARGET_APK%
echo.

REM Open the folder
explorer %OUTPUT_DIR%

pause
