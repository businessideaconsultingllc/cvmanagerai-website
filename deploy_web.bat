@echo off
setlocal

echo =======================================================
echo CV Manager AI - Web Deployment Script
echo =======================================================
echo.

echo 1. Building Flutter Web App (Base href: /app/)...
call flutter build web --base-href /app/ --release
if %errorlevel% neq 0 (
    echo [ERROR] Build failed!
    exit /b %errorlevel%
)
echo [SUCCESS] Build completed.
echo.

set DEPLOY_DIR=_deploy_temp_cvmanager

echo 2. Preparing deployment workspace...
if exist %DEPLOY_DIR% (
    echo Cleaning up previous temp folder...
    rmdir /s /q %DEPLOY_DIR%
)

echo 3. Cloning website repository (main branch)...
git clone --depth 1 https://github.com/businessideaconsultingllc/cvmanagerai-website.git %DEPLOY_DIR%
if %errorlevel% neq 0 (
    echo [ERROR] Git clone failed. Please check your internet connection or git credentials.
    exit /b %errorlevel%
)

echo 4. Updating '/app' directory content...
cd %DEPLOY_DIR%

REM Configure Git for this transaction to avoid "identity unknown" errors
git config user.email "deploy@local.script"
git config user.name "Deployment Script"

REM Clean existing app folder to remove stale files
if exist app (
    rmdir /s /q app
)
mkdir app

REM Copy new build artifacts to app folder
cd ..
xcopy /s /y /e build\web\*.* %DEPLOY_DIR%\app\ >nul
if %errorlevel% neq 0 (
    echo [ERROR] Failed to copy build files.
    exit /b %errorlevel%
)

echo 4b. Copying Landing Page and Site files...
xcopy /s /y /e assets %DEPLOY_DIR%\assets\ >nul
copy index.html %DEPLOY_DIR%\index.html >nul
copy ads.txt %DEPLOY_DIR%\ads.txt >nul
copy robots.txt %DEPLOY_DIR%\robots.txt >nul
copy sitemap.xml %DEPLOY_DIR%\sitemap.xml >nul
copy privacy.html %DEPLOY_DIR%\privacy.html >nul
copy terms.html %DEPLOY_DIR%\terms.html >nul
copy contact.html %DEPLOY_DIR%\contact.html >nul
copy favicon.png %DEPLOY_DIR%\favicon.png >nul
copy CNAME %DEPLOY_DIR%\CNAME >nul
if %errorlevel% neq 0 (
    echo [ERROR] Failed to copy site files.
    exit /b %errorlevel%
)

echo 5. Committing and Pushing changes...
cd %DEPLOY_DIR%
git add .
git commit -m "Update Flutter App (Automated Deploy)"

REM Push to main
git push origin main
if %errorlevel% neq 0 (
    echo [ERROR] Git push failed.
    echo You may need to authenticate manually.
    cd ..
    exit /b %errorlevel%
)

echo.
echo [SUCCESS] Deployment completed successfully!
echo The app should be live at: https://cvmanagerai.com/app/
echo.

cd ..
REM Cleanup
rmdir /s /q %DEPLOY_DIR%

pause
