@echo off
setlocal enabledelayedexpansion

:: ==================== CONFIGURATION ====================
:: Set your Gitea repository details here

:: ==================== CONFIGURATION ====================
:: Set your Gitea repository details here
set "GITEA_URL=https://gitea.wgn.wuerth.com"
set "GITEA_OWNER=WN00224895"
set "GITEA_REPO=Datenvalidator_Batch"
set "GITEA_TOKEN_FILE=.gitea_token"
set "REMOTE_NAME=%GITEA_REPO%"

:: Files
set "TAG_FILE=.currenttag"
set "RELEASE_NOTES=release.md"
set "ZIP_FILE=datenvalidator.zip"

:: ==================== HEADER ====================
cls
echo ========================================
echo   CREATE RELEASE TAG FOR GITEA
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

:: Check if curl is available (for Gitea API)
where curl >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [WARNING] curl is not installed or not in PATH!
    echo Without curl, automatic release upload to Gitea won't work.
    echo You can still create the tag and upload manually.
    set "CURL_AVAILABLE=0"
) else (
    set "CURL_AVAILABLE=1"
    echo curl found - automatic Gitea release upload available
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

:: ==================== GITEA TOKEN HANDLING ====================
set "GITEA_TOKEN="
if "%CURL_AVAILABLE%"=="1" (
    if exist "%GITEA_TOKEN_FILE%" (
        set /p GITEA_TOKEN=<"%GITEA_TOKEN_FILE%"
        echo Gitea token loaded from file
    ) else (
        echo.
        echo To enable automatic Gitea release upload, you need an access token.
        echo.
        echo To create one:
        echo 1. Go to %GITEA_URL%/user/settings/applications
        echo 2. Generate New Token with 'repo' scope
        echo 3. Copy the token
        echo.
        set /p "SAVE_TOKEN=Do you want to enter a Gitea token now? (y/n): "
        if /i "!SAVE_TOKEN!"=="y" (
            set /p "GITEA_TOKEN=Enter your Gitea token: "
            if not "!GITEA_TOKEN!"=="" (
                echo !GITEA_TOKEN!>"%GITEA_TOKEN_FILE%"
                echo Token saved to %GITEA_TOKEN_FILE%
                attrib +h "%GITEA_TOKEN_FILE%" 2>nul
            )
        )
    )
)

:: ==================== GET/INCREMENT TAG NUMBER ====================
echo.
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
    git push %REMOTE_NAME% HEAD
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
git push %REMOTE_NAME% "!RELEASE_TAG!"
if %ERRORLEVEL% neq 0 (
    echo [WARNING] Failed to push tag to remote!
    echo You can manually push later with:
    echo   git push %REMOTE_NAME% "!RELEASE_TAG!"
    echo.
) else (
    echo Tag pushed successfully!
)
echo.

:: ==================== CREATE GITEA RELEASE ====================
if "%CURL_AVAILABLE%"=="1" if not "!GITEA_TOKEN!"=="" (
    echo Creating Gitea release via API...
    echo.
    
    :: Read release notes into variable
    set "RELEASE_BODY="
    for /f "usebackq delims=" %%a in ("%RELEASE_NOTES%") do (
        set "LINE=%%a"
        :: Escape quotes and backslashes for JSON
        set "LINE=!LINE:\=\\!"
        set "LINE=!LINE:"=\"!"
        if defined RELEASE_BODY (
            set "RELEASE_BODY=!RELEASE_BODY!\n!LINE!"
        ) else (
            set "RELEASE_BODY=!LINE!"
        )
    )
    
    :: Create JSON payload for release
    (
        echo {
        echo   "tag_name": "!RELEASE_TAG!",
        echo   "name": "Release !RELEASE_TAG!",
        echo   "body": "!RELEASE_BODY!",
        echo   "draft": false,
        echo   "prerelease": false
        echo }
    ) > release_payload.json
    
    :: Create the release
    curl -X POST ^
        -H "Authorization: token !GITEA_TOKEN!" ^
        -H "Content-Type: application/json" ^
        -d @release_payload.json ^
        "%GITEA_URL%/api/v1/repos/%GITEA_OWNER%/%GITEA_REPO%/releases" ^
        -o release_response.json 2>nul
    
    if %ERRORLEVEL% equ 0 (
        echo Release created on Gitea!
        
        :: Extract release ID from response (simplified parsing)
        for /f "tokens=2 delims=:," %%a in ('findstr /C:"\"id\"" release_response.json') do (
            set "RELEASE_ID=%%a"
            :: Remove spaces and quotes
            set "RELEASE_ID=!RELEASE_ID: =!"
            set "RELEASE_ID=!RELEASE_ID:"=!"
            goto :upload_asset
        )
        
        :upload_asset
        if defined RELEASE_ID (
            echo Uploading ZIP file to release ID: !RELEASE_ID!
            
            :: Upload the ZIP file as an asset
            curl -X POST ^
                -H "Authorization: token !GITEA_TOKEN!" ^
                -H "Content-Type: application/zip" ^
                --data-binary "@%ZIP_FILE%" ^
                "%GITEA_URL%/api/v1/repos/%GITEA_OWNER%/%GITEA_REPO%/releases/!RELEASE_ID!/assets?name=%ZIP_FILE%" ^
                -o asset_response.json 2>nul
            
            if %ERRORLEVEL% equ 0 (
                echo.
                echo [SUCCESS] ZIP file uploaded to Gitea release!
                echo.
                echo Release URL: %GITEA_URL%/%GITEA_OWNER%/%GITEA_REPO%/releases/tag/!RELEASE_TAG!
            ) else (
                echo [WARNING] Failed to upload ZIP file to release
                echo You can manually upload it at: %GITEA_URL%/%GITEA_OWNER%/%GITEA_REPO%/releases
            )
        )
        
        :: Clean up temporary files
        del release_payload.json 2>nul
        del release_response.json 2>nul
        del asset_response.json 2>nul
        
    ) else (
        echo [WARNING] Failed to create Gitea release via API
        echo You can create it manually at: %GITEA_URL%/%GITEA_OWNER%/%GITEA_REPO%/releases/new
        del release_payload.json 2>nul
    )
) else (
    echo.
    echo Manual release creation required:
    echo.
    echo 1. Go to: %GITEA_URL%/%GITEA_OWNER%/%GITEA_REPO%/releases/new
    echo 2. Select tag: !RELEASE_TAG!
    echo 3. Title: Release !RELEASE_TAG!
    echo 4. Upload: %ZIP_FILE%
    echo 5. Copy release notes from: %RELEASE_NOTES%
    echo.
    if "%CURL_AVAILABLE%"=="0" (
        echo Note: Install curl to enable automatic uploads
    ) else (
        echo Note: Configure Gitea token to enable automatic uploads
    )
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
echo   git push %REMOTE_NAME% --delete "!RELEASE_TAG!"
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