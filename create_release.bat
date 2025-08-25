@echo off
setlocal enabledelayedexpansion

:: ==================== CONFIGURATION ====================
:: Set your Gitea repository details here
set "GITEA_URL=https://gitea.wgn.wuerth.com"
set "GITEA_OWNER=WN00224895"
set "GITEA_REPO=Datenvalidator_Batch"
set "GITEA_TOKEN_FILE=.gitea_token"
set "REMOTE_NAME=origin"

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

:: ==================== SHOW CURRENT DIRECTORY ====================
echo Current directory: %CD%
echo.

:: ==================== CLEAR ANY GIT ENVIRONMENT VARIABLES ====================
:: This prevents Git from using wrong directories
set "GIT_DIR="
set "GIT_WORK_TREE="

:: ==================== CHECK PREREQUISITES ====================
:: Check if git is available
where git >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Git is not installed or not in PATH!
    goto :error
)

:: Find curl in Git installation
set "CURL_CMD=curl"
set "CURL_AVAILABLE=0"

for /f "tokens=*" %%i in ('where git 2^>nul') do (
    set "GIT_EXE_PATH=%%~dpi"
    :: Remove trailing backslash
    set "GIT_EXE_PATH=!GIT_EXE_PATH:~0,-1!"
    :: Go up one directory from bin
    for %%j in ("!GIT_EXE_PATH!") do set "GIT_INSTALL_DIR=%%~dpj"
    goto :found_git_exe
)
:found_git_exe

if defined GIT_INSTALL_DIR (
    echo Git installation found at: !GIT_INSTALL_DIR!
    
    :: Look for curl in Git installation
    if exist "!GIT_INSTALL_DIR!usr\bin\curl.exe" (
        set "CURL_CMD=!GIT_INSTALL_DIR!usr\bin\curl.exe"
        echo Found curl at: !CURL_CMD!
        set "CURL_AVAILABLE=1"
    ) else if exist "!GIT_INSTALL_DIR!mingw64\bin\curl.exe" (
        set "CURL_CMD=!GIT_INSTALL_DIR!mingw64\bin\curl.exe"
        echo Found curl at: !CURL_CMD!
        set "CURL_AVAILABLE=1"
    )
)

:: If curl not found in Git, try system curl
if "%CURL_AVAILABLE%"=="0" (
    where curl >nul 2>&1
    if !ERRORLEVEL! equ 0 (
        set "CURL_CMD=curl"
        set "CURL_AVAILABLE=1"
        echo Using system curl
    ) else (
        echo curl not found - manual release creation will be required
    )
)

:: ==================== CHECK GIT REPOSITORY ====================
echo.
echo Checking Git repository status...

:: Check if .git directory exists in current directory
if not exist ".git" (
    echo [ERROR] No .git directory found in current directory!
    echo.
    echo Current directory: %CD%
    echo.
    echo Please navigate to your Git repository and run this script again.
    echo Expected: Navigate to the Datenvalidator_Batch repository folder
    goto :error
)

:: Verify it's a valid git repository using explicit work tree
git --git-dir="%CD%\.git" --work-tree="%CD%" rev-parse --is-inside-work-tree >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Invalid Git repository!
    echo Please ensure the .git directory is valid.
    goto :error
)

echo Git repository confirmed.

:: ==================== CHECK REMOTE AUTHENTICATION ====================
echo.
echo Checking remote authentication...

:: Get remote URL
for /f "tokens=*" %%i in ('git --git-dir^="%CD%\.git" --work-tree^="%CD%" remote get-url %REMOTE_NAME% 2^>nul') do set REMOTE_URL=%%i
if defined REMOTE_URL (
    echo Remote URL: %REMOTE_URL%
    
    :: Test remote connectivity
    echo Testing connection to remote...
    git --git-dir="%CD%\.git" --work-tree="%CD%" ls-remote %REMOTE_NAME% HEAD >nul 2>&1
    if %ERRORLEVEL% neq 0 (
        echo [WARNING] Cannot connect to remote repository!
        echo.
        echo This could mean:
        echo 1. You're not authenticated (need to login)
        echo 2. No internet connection
        echo 3. Remote repository doesn't exist
        echo.
        
        set /p "CONTINUE_OFFLINE=Do you want to continue offline? (y/n): "
        if /i not "!CONTINUE_OFFLINE!"=="y" (
            echo.
            echo To authenticate with Gitea:
            echo 1. Run: git push
            echo 2. Enter your credentials when prompted
            echo 3. Run this script again
            goto :error
        )
        echo Continuing in offline mode - tags will be created locally only
        set "OFFLINE_MODE=1"
    ) else (
        echo Remote connection successful!
        set "OFFLINE_MODE=0"
    )
) else (
    echo [WARNING] No remote '%REMOTE_NAME%' configured
    set "OFFLINE_MODE=1"
)

:: Show current branch
for /f "tokens=*" %%i in ('git --git-dir^="%CD%\.git" --work-tree^="%CD%" branch --show-current 2^>nul') do set CURRENT_BRANCH=%%i
if defined CURRENT_BRANCH (
    echo Current branch: %CURRENT_BRANCH%
)
echo.

:: ==================== CHECK FOR REQUIRED FILES ====================
echo Checking for required files...

:: Check if ZIP file exists
if not exist "%ZIP_FILE%" (
    echo [ERROR] ZIP file not found: %ZIP_FILE%
    echo.
    echo Available ZIP files:
    dir *.zip 2>nul
    if %ERRORLEVEL% neq 0 (
        echo No ZIP files found in current directory
    )
    echo.
    echo Please run the build script first to create %ZIP_FILE%
    goto :error
) else (
    echo Found: %ZIP_FILE%
    for %%A in ("%ZIP_FILE%") do echo Size: %%~zA bytes
)

:: Check if release notes exist
if not exist "%RELEASE_NOTES%" (
    echo [WARNING] Release notes not found: %RELEASE_NOTES%
    echo Creating default release notes...
    echo # Release Notes > "%RELEASE_NOTES%"
    echo. >> "%RELEASE_NOTES%"
    echo ## Build Information >> "%RELEASE_NOTES%"
    echo - Date: %DATE% %TIME% >> "%RELEASE_NOTES%"
    echo - User: %USERNAME% >> "%RELEASE_NOTES%"
    echo - Machine: %COMPUTERNAME% >> "%RELEASE_NOTES%"
    echo. >> "%RELEASE_NOTES%"
    echo ## Changes >> "%RELEASE_NOTES%"
    echo - Compiled build >> "%RELEASE_NOTES%"
    echo. >> "%RELEASE_NOTES%"
    echo ## Files >> "%RELEASE_NOTES%"
    echo - %ZIP_FILE% >> "%RELEASE_NOTES%"
) else (
    echo Found: %RELEASE_NOTES%
)

echo.

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

:: Clean tag number - ensure it's numeric
set /a TAG_NUM=TAG_NUM 2>nul
if %ERRORLEVEL% neq 0 (
    echo Invalid tag number, resetting to 0
    set TAG_NUM=0
)

:: Increment tag number
set /a TAG_NUM+=1
echo !TAG_NUM!>"%TAG_FILE%"
echo New tag number: !TAG_NUM!
echo.

:: ==================== GET VERSION FROM USER ====================
:: Get last commit message
for /f "tokens=*" %%i in ('git --git-dir^="%CD%\.git" --work-tree^="%CD%" log -1 --pretty^=format:"%%s" 2^>nul') do set COMMIT_MSG=%%i
if defined COMMIT_MSG (
    echo Last commit: %COMMIT_MSG%
)
echo.

echo Enter version number (e.g., 0.5007 or just 5007):
set /p VERSION=
echo.

if "!VERSION!"=="" (
    echo No version entered, using default: 1.0.0
    set VERSION=1.0.0
)

:: Clean version string
set "VERSION=!VERSION: =!"
set "CLEAN_VERSION="
set "VALID_CHARS=0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ.-_"

set "i=0"
:clean_loop
if "!VERSION:~%i%,1!"=="" goto :clean_done
set "CHAR=!VERSION:~%i%,1!"
set "IS_VALID=0"
for /l %%j in (0,1,70) do (
    if "!CHAR!"=="!VALID_CHARS:~%%j,1!" set IS_VALID=1
)
if "!IS_VALID!"=="1" (
    set "CLEAN_VERSION=!CLEAN_VERSION!!CHAR!"
) else (
    if not "!CLEAN_VERSION:~-1!"=="_" (
        set "CLEAN_VERSION=!CLEAN_VERSION!_"
    )
)
set /a i+=1
goto :clean_loop

:clean_done
:remove_trailing
if "!CLEAN_VERSION:~-1!"=="_" (
    set "CLEAN_VERSION=!CLEAN_VERSION:~0,-1!"
    goto :remove_trailing
)

if "!CLEAN_VERSION!"=="" (
    set "CLEAN_VERSION=unknown"
)

if not "!CLEAN_VERSION:~30!"=="" (
    set "CLEAN_VERSION=!CLEAN_VERSION:~0,30!"
)

set "RELEASE_TAG=v!CLEAN_VERSION!_!TAG_NUM!"

echo Version: !CLEAN_VERSION!
echo Tag: !RELEASE_TAG!
echo.

:: ==================== COMMIT AND TAG ====================
echo Checking for uncommitted changes...
git --git-dir="%CD%\.git" --work-tree="%CD%" status --porcelain >temp_status.txt 2>nul
set "HAS_CHANGES=0"
for /f "usebackq" %%i in ("temp_status.txt") do set HAS_CHANGES=1
del temp_status.txt 2>nul

if %HAS_CHANGES% equ 1 (
    echo Found uncommitted changes, committing...
    git --git-dir="%CD%\.git" --work-tree="%CD%" add -A
    git --git-dir="%CD%\.git" --work-tree="%CD%" commit -m "Pre-release commit for !RELEASE_TAG!"
    
    if "%OFFLINE_MODE%"=="0" (
        echo Pushing changes to remote...
        git --git-dir="%CD%\.git" --work-tree="%CD%" push %REMOTE_NAME% HEAD 2>nul
        if !ERRORLEVEL! neq 0 (
            echo [WARNING] Could not push changes
        )
    ) else (
        echo [INFO] Offline mode - changes not pushed
    )
)
echo.

echo Creating tag: !RELEASE_TAG!

:: Create the tag with explicit git directory
git --git-dir="%CD%\.git" --work-tree="%CD%" tag -a "!RELEASE_TAG!" -F "%RELEASE_NOTES%" 2>git_error.txt
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Failed to create tag!
    echo.
    echo Error details:
    type git_error.txt
    del git_error.txt 2>nul
    echo.
    echo If tag already exists, delete it with:
    echo   git --git-dir="%CD%\.git" --work-tree="%CD%" tag -d "!RELEASE_TAG!"
    goto :error
)
del git_error.txt 2>nul

echo Tag created successfully!

if "%OFFLINE_MODE%"=="0" (
    echo Pushing tag to remote...
    git --git-dir="%CD%\.git" --work-tree="%CD%" push %REMOTE_NAME% "!RELEASE_TAG!" 2>git_push_error.txt
    if %ERRORLEVEL% neq 0 (
        echo [WARNING] Failed to push tag!
        type git_push_error.txt
        del git_push_error.txt 2>nul
        echo.
        echo You can push it manually later with:
        echo   git push %REMOTE_NAME% "!RELEASE_TAG!"
    ) else (
        echo Tag pushed successfully!
        del git_push_error.txt 2>nul
    )
) else (
    echo [INFO] Offline mode - tag created locally only
    echo Push it later with: git push %REMOTE_NAME% "!RELEASE_TAG!"
)
echo.

:: ==================== CREATE GITEA RELEASE ====================
if "%OFFLINE_MODE%"=="0" if "%CURL_AVAILABLE%"=="1" if not "!GITEA_TOKEN!"=="" (
    echo Creating Gitea release via API...
    echo.
    
    :: Prepare release body - escape for JSON
    set "BODY_TEXT=Release !RELEASE_TAG!"
    if exist "%RELEASE_NOTES%" (
        set "BODY_TEXT="
        for /f "usebackq delims=" %%a in ("%RELEASE_NOTES%") do (
            set "LINE=%%a"
            :: Basic JSON escaping
            set "LINE=!LINE:\=\\!"
            set "LINE=!LINE:"=\"!"
            set "LINE=!LINE:	=    !"
            if defined BODY_TEXT (
                set "BODY_TEXT=!BODY_TEXT!\n!LINE!"
            ) else (
                set "BODY_TEXT=!LINE!"
            )
        )
    )
    
    :: Create JSON file
    echo Creating release.json...
    echo { > release.json
    echo   "tag_name": "!RELEASE_TAG!", >> release.json
    echo   "name": "Release !RELEASE_TAG!", >> release.json
    echo   "body": "!BODY_TEXT!", >> release.json
    echo   "draft": false, >> release.json
    echo   "prerelease": false >> release.json
    echo } >> release.json
    
    :: Create release using curl
    echo Calling Gitea API...
    "!CURL_CMD!" -X POST ^
        -H "Authorization: token !GITEA_TOKEN!" ^
        -H "Content-Type: application/json" ^
        -d @release.json ^
        "!GITEA_URL!/api/v1/repos/!GITEA_OWNER!/!GITEA_REPO!/releases" ^
        -o response.json 2>curl_error.txt
    
    set CURL_EXIT=!ERRORLEVEL!
    
    if !CURL_EXIT! equ 0 (
        :: Check if we got a valid response with an ID
        findstr /C:"\"id\"" response.json >nul 2>&1
        if !ERRORLEVEL! equ 0 (
            echo Release created successfully!
            
            :: Extract release ID
            for /f "tokens=2 delims=:," %%a in ('findstr /C:"\"id\"" response.json') do (
                set "RELEASE_ID=%%a"
                :: Remove spaces and quotes
                set "RELEASE_ID=!RELEASE_ID: =!"
                set "RELEASE_ID=!RELEASE_ID:"=!"
                goto :got_id
            )
            :got_id
            
            if defined RELEASE_ID (
                echo Uploading ZIP file to release ID: !RELEASE_ID!
                
                :: Upload asset
                "!CURL_CMD!" -X POST ^
                    -H "Authorization: token !GITEA_TOKEN!" ^
                    -H "Content-Type: application/zip" ^
                    --data-binary "@!ZIP_FILE!" ^
                    "!GITEA_URL!/api/v1/repos/!GITEA_OWNER!/!GITEA_REPO!/releases/!RELEASE_ID!/assets?name=!ZIP_FILE!" ^
                    -o asset_response.json 2>asset_error.txt
                
                if !ERRORLEVEL! equ 0 (
                    echo.
                    echo [SUCCESS] ZIP file uploaded to Gitea release!
                    echo.
                    echo Release URL: !GITEA_URL!/!GITEA_OWNER!/!GITEA_REPO!/releases/tag/!RELEASE_TAG!
                ) else (
                    echo [WARNING] Failed to upload ZIP file
                )
            )
        ) else (
            echo [WARNING] Release creation may have failed
            echo Check: !GITEA_URL!/!GITEA_OWNER!/!GITEA_REPO!/releases
        )
    ) else (
        echo [ERROR] curl failed
    )
    
    :: Cleanup
    del release.json 2>nul
    del response.json 2>nul
    del asset_response.json 2>nul
    del curl_error.txt 2>nul
    del asset_error.txt 2>nul
    
) else (
    echo.
    if "%OFFLINE_MODE%"=="1" (
        echo Offline mode - Gitea release not created
    ) else if "%CURL_AVAILABLE%"=="0" (
        echo curl not available - Manual upload required
    ) else (
        echo No Gitea token - Manual upload required
    )
    echo.
    echo Manual release creation:
    echo 1. Push the tag first: git push %REMOTE_NAME% !RELEASE_TAG!
    echo 2. Go to: %GITEA_URL%/%GITEA_OWNER%/%GITEA_REPO%/releases/new
    echo 3. Select tag: !RELEASE_TAG!
    echo 4. Title: Release !RELEASE_TAG!
    echo 5. Upload: %ZIP_FILE%
)

:: ==================== SUCCESS ====================
echo.
echo ========================================
echo   RELEASE COMPLETED!
echo ========================================
echo.
echo Tag: !RELEASE_TAG!
echo Version: !CLEAN_VERSION!
echo Build: !TAG_NUM!
if "%OFFLINE_MODE%"=="1" (
    echo Mode: OFFLINE (push manually later)
)
echo.
echo Repository: !GITEA_URL!/!GITEA_OWNER!/!GITEA_REPO!
echo.
echo Useful commands:
echo   View tag: git show !RELEASE_TAG!
echo   Delete tag: git tag -d "!RELEASE_TAG!"
if "%OFFLINE_MODE%"=="1" (
    echo   Push tag: git push %REMOTE_NAME% !RELEASE_TAG!
)
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