@echo off
setlocal enabledelayedexpansion

:: ==================== CONFIGURATION ====================
:: Set your repository details here
set "GITHUB_OWNER=your-username"
set "GITHUB_REPO=your-repo-name"
set "TAG_FILE=.currenttag"
set "RELEASE_NOTES=release.md"
set "ZIP_FILE=datenvalidator.zip"

:: ==================== HEADER ====================
cls
echo ========================================
echo   CREATE RELEASE TAG
echo   Date: %DATE% %TIME%
echo ========================================
echo.

:: ==================== CHECK PREREQUISITES ====================
:: Check if git is available
where git >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Git is not installed or not in PATH!
    goto :error
)

:: Check if we're in a git repository
git rev-parse --git-dir >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Current directory is not a Git repository!
    goto :error
)

:: Check if ZIP file exists
if not exist "%ZIP_FILE%" (
    echo [ERROR] ZIP file not found: %ZIP_FILE%
    echo Please run the build script first!
    goto :error
)

:: Check if release notes exist
if not exist "%RELEASE_NOTES%" (
    echo [WARNING] Release notes not found: %RELEASE_NOTES%
    echo Creating default release notes...
    (
        echo # Release Notes
        echo.
        echo ## Build Information
        echo - Date: %DATE% %TIME%
        echo - User: %USERNAME%
        echo - Machine: %COMPUTERNAME%
        echo.
        echo ## Changes
        echo - Compiled build
        echo.
        echo ## Files
        echo - %ZIP_FILE%
    ) > "%RELEASE_NOTES%"
)

:: ==================== GET/INCREMENT TAG NUMBER ====================
echo Reading tag number...
if exist "%TAG_FILE%" (
    set /p TAG_NUM=<"%TAG_FILE%"
) else (
    echo No tag file found, starting at 1
    set TAG_NUM=0
)

:: Increment tag number
set /a TAG_NUM+=1
echo !TAG_NUM!>"%TAG_FILE%"
echo New tag number: !TAG_NUM!
echo.

:: ==================== GET VERSION FROM LAST COMMIT OR USER ====================
:: Try to extract version from last commit message
for /f "tokens=*" %%i in ('git log -1 --pretty^=format:"%%s"') do set COMMIT_MSG=%%i
echo Last commit: %COMMIT_MSG%
echo.

:: Try to extract version from commit message (looks for v0.5006 pattern)
set "VERSION="
for /f "tokens=2 delims=v" %%i in ('echo %COMMIT_MSG% ^| findstr /r "v[0-9]"') do (
    for /f "tokens=1 delims= " %%j in ('echo %%i') do set VERSION=%%j
)

:: If no version found, ask user
if "%VERSION%"=="" (
    echo No version found in commit message.
    set /p VERSION="Enter version number (e.g., 0.5006): "
)

:: Clean version string - FIXED VERSION
set "CLEAN_VERSION=!VERSION!"
:: Remove spaces
set "CLEAN_VERSION=!CLEAN_VERSION: =_!"
:: Remove forward slashes
set "CLEAN_VERSION=!CLEAN_VERSION:/=_!"
:: Remove backslashes
set "CLEAN_VERSION=!CLEAN_VERSION:\=_!"
:: Remove pipe characters
set "CLEAN_VERSION=!CLEAN_VERSION:|=_!"
:: Remove question marks - FIXED: escaped properly
set "CLEAN_VERSION=!CLEAN_VERSION:?=_!"
:: Remove asterisks - FIXED: don't use *= syntax
for /f "delims=" %%a in ('echo !CLEAN_VERSION! ^| powershell -Command "$input -replace '\*', '_'"') do set "CLEAN_VERSION=%%a"
:: Remove quotes
set CLEAN_VERSION=!CLEAN_VERSION:"=_!
:: Remove less than
set "CLEAN_VERSION=!CLEAN_VERSION:<=_!"
:: Remove greater than  
set "CLEAN_VERSION=!CLEAN_VERSION:>=_!"

:: Limit to 30 characters
if "!CLEAN_VERSION:~30!" neq "" (
    set "CLEAN_VERSION=!CLEAN_VERSION:~0,30!"
)

:: Create release tag name
set "RELEASE_TAG=v!CLEAN_VERSION!_!TAG_NUM!"
echo Release tag: !RELEASE_TAG!
echo.

:: ==================== ENSURE ALL CHANGES ARE COMMITTED ====================
echo Checking for uncommitted changes...
git status --porcelain >temp_status.txt 2>nul
set "STATUS="
if exist temp_status.txt (
    set /p STATUS=<temp_status.txt
    del temp_status.txt
)

if not "!STATUS!"=="" (
    echo Found uncommitted changes, committing...
    git add -A
    git commit -m "Pre-release commit for !RELEASE_TAG!"
    git push
) else (
    echo No uncommitted changes.
)
echo.

:: ==================== CREATE GIT TAG ====================
echo Creating annotated tag: !RELEASE_TAG!
echo.

:: Create tag with message from release notes
git tag -a "!RELEASE_TAG!" -F "%RELEASE_NOTES%"
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Failed to create tag!
    echo.
    echo If tag already exists, you can delete it with:
    echo   git tag -d !RELEASE_TAG!
    echo Or force overwrite with:
    echo   git tag -f -a "!RELEASE_TAG!" -F "%RELEASE_NOTES%"
    goto :error
)

echo Tag created successfully!
echo.

:: ==================== PUSH TAG TO REMOTE ====================
echo Pushing tag to remote repository...
git push origin "!RELEASE_TAG!"
if %ERRORLEVEL% neq 0 (
    echo [WARNING] Failed to push tag to remote!
    echo You can manually push later with:
    echo   git push origin !RELEASE_TAG!
    echo.
)
echo.

:: ==================== CREATE GITHUB RELEASE (if gh CLI available) ====================
where gh >nul 2>&1
if %ERRORLEVEL% equ 0 (
    echo GitHub CLI detected, creating release...
    
    gh release create "!RELEASE_TAG!" "%ZIP_FILE%" ^
        --title "Release !RELEASE_TAG!" ^
        --notes-file "%RELEASE_NOTES%"
    
    if %ERRORLEVEL% equ 0 (
        echo.
        echo [SUCCESS] GitHub release created!
        echo URL: https://github.com/%GITHUB_OWNER%/%GITHUB_REPO%/releases/tag/!RELEASE_TAG!
    ) else (
        echo [WARNING] Failed to create GitHub release.
        echo You can create it manually at:
        echo https://github.com/%GITHUB_OWNER%/%GITHUB_REPO%/releases/new
    )
) else (
    echo.
    echo GitHub CLI not found. To create a release automatically, install gh:
    echo   https://cli.github.com/
    echo.
    echo Manual release instructions:
    echo 1. Go to: https://github.com/%GITHUB_OWNER%/%GITHUB_REPO%/releases/new
    echo 2. Tag: !RELEASE_TAG!
    echo 3. Upload: %ZIP_FILE%
    echo 4. Copy release notes from: %RELEASE_NOTES%
)

:: ==================== SUCCESS ====================
echo.
echo ========================================
echo   RELEASE TAG CREATED SUCCESSFULLY!
echo ========================================
echo.
echo Tag: !RELEASE_TAG!
echo Version: !CLEAN_VERSION!
echo Build: !TAG_NUM!
echo.
echo To view the tag:
echo   git show !RELEASE_TAG!
echo.
echo To list all tags:
echo   git tag -l
echo.
echo To delete this tag (if needed):
echo   git tag -d !RELEASE_TAG!
echo   git push origin --delete !RELEASE_TAG!
echo.

pause
exit /b 0

:: ==================== ERROR HANDLER ====================
:error
echo.
echo ========================================
echo   RELEASE CREATION FAILED!
echo ========================================
echo.
pause
exit /b 1