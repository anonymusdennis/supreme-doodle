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

:: Clean tag number (remove spaces and non-numeric chars)
set "CLEAN_TAG_NUM="
for /f "delims=0123456789" %%i in ("!TAG_NUM!") do set CLEAN_TAG_NUM=%%i
if defined CLEAN_TAG_NUM (
    echo Invalid tag number, resetting to 0
    set TAG_NUM=0
)

:: Increment tag number
set /a TAG_NUM+=1
echo !TAG_NUM!>"%TAG_FILE%"
echo New tag number: !TAG_NUM!
echo.

:: ==================== GET VERSION FROM USER ====================
:: Try to extract version from last commit message
for /f "tokens=*" %%i in ('git log -1 --pretty^=format:"%%s"') do set COMMIT_MSG=%%i
echo Last commit: %COMMIT_MSG%
echo.

echo Enter version number (e.g., 0.5007 or just 5007):
set /p VERSION=
echo.

:: If empty, use a default
if "!VERSION!"=="" (
    echo No version entered, using default: 1.0.0
    set VERSION=1.0.0
)

:: Clean version string - remove ALL spaces first
set "VERSION=!VERSION: =!"

:: Clean version - simple character-by-character approach
set "CLEAN_VERSION="
set "VALID_CHARS=0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ.-_"

:: Process each character
set "i=0"
:clean_loop
if "!VERSION:~%i%,1!"=="" goto :clean_done
set "CHAR=!VERSION:~%i%,1!"

:: Check if character is valid
set "IS_VALID=0"
for /l %%j in (0,1,70) do (
    if "!CHAR!"=="!VALID_CHARS:~%%j,1!" set IS_VALID=1
)

:: Add character if valid, underscore if not
if "!IS_VALID!"=="1" (
    set "CLEAN_VERSION=!CLEAN_VERSION!!CHAR!"
) else (
    :: Only add underscore if last char wasn't underscore
    if not "!CLEAN_VERSION:~-1!"=="_" (
        set "CLEAN_VERSION=!CLEAN_VERSION!_"
    )
)

set /a i+=1
goto :clean_loop

:clean_done

:: Remove trailing underscores
:remove_trailing
if "!CLEAN_VERSION:~-1!"=="_" (
    set "CLEAN_VERSION=!CLEAN_VERSION:~0,-1!"
    goto :remove_trailing
)

:: If clean version is empty, use default
if "!CLEAN_VERSION!"=="" (
    set "CLEAN_VERSION=unknown"
)

:: Limit to 30 characters
if not "!CLEAN_VERSION:~30!"=="" (
    set "CLEAN_VERSION=!CLEAN_VERSION:~0,30!"
)

:: Create release tag name
set "RELEASE_TAG=v!CLEAN_VERSION!_!TAG_NUM!"

echo Original version: !VERSION!
echo Cleaned version: !CLEAN_VERSION!
echo Tag Number: !TAG_NUM!
echo Final Release tag: !RELEASE_TAG!
echo.

:: Double-check no spaces
set "SPACE_CHECK=!RELEASE_TAG: =X!"
if not "!SPACE_CHECK!"=="!RELEASE_TAG!" (
    echo [ERROR] Tag still contains spaces somehow!
    echo Tag: "!RELEASE_TAG!"
    goto :error
)

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
    echo Attempted tag name: "!RELEASE_TAG!"
    echo.
    echo If tag already exists, you can delete it with:
    echo   git tag -d "!RELEASE_TAG!"
    echo.
    echo Or force overwrite with:
    echo   git tag -f -a "!RELEASE_TAG!" -F "%RELEASE_NOTES%"
    echo.
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
    echo   git push origin "!RELEASE_TAG!"
    echo.
) else (
    echo Tag pushed successfully!
)
echo.

:: ==================== CREATE GITHUB/GITEA RELEASE ====================
where gh >nul 2>&1
if %ERRORLEVEL% equ 0 (
    echo GitHub CLI detected, creating release...
    
    gh release create "!RELEASE_TAG!" "%ZIP_FILE%" ^
        --title "Release !RELEASE_TAG!" ^
        --notes-file "%RELEASE_NOTES%"
    
    if %ERRORLEVEL% equ 0 (
        echo.
        echo [SUCCESS] GitHub release created!
    ) else (
        echo [WARNING] Failed to create GitHub release.
    )
) else (
    echo.
    echo GitHub CLI not found. 
    echo.
    echo To create a release on Gitea:
    echo 1. Go to your repository on Gitea
    echo 2. Click on "Releases" 
    echo 3. Click "New Release"
    echo 4. Select tag: !RELEASE_TAG!
    echo 5. Upload: %ZIP_FILE%
    echo 6. Copy release notes from: %RELEASE_NOTES%
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
echo To delete this tag if needed:
echo   git tag -d "!RELEASE_TAG!"
echo   git push origin --delete "!RELEASE_TAG!"
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
echo Check the error messages above.
echo.
pause
exit /b 1