@echo off
setlocal enabledelayedexpansion

:: ==================== CHECK IF RUNNING IN GIT BASH ====================
if not defined MSYSTEM (
    echo Not running in Git Bash, restarting in Git Bash...
    echo.
    
    :: Find git-bash.exe
    set "GIT_BASH="
    
    :: Check common locations
    if exist "C:\Program Files\Git\git-bash.exe" (
        set "GIT_BASH=C:\Program Files\Git\git-bash.exe"
    ) else if exist "C:\Program Files (x86)\Git\git-bash.exe" (
        set "GIT_BASH=C:\Program Files (x86)\Git\git-bash.exe"
    ) else if exist "%LOCALAPPDATA%\Programs\Git\git-bash.exe" (
        set "GIT_BASH=%LOCALAPPDATA%\Programs\Git\git-bash.exe"
    ) else (
        echo [ERROR] Could not find git-bash.exe
        echo Please install Git for Windows
        pause
        exit /b 1
    )
    
    :: Convert Windows path to Unix path for Git Bash
    set "UNIX_PATH=%CD%"
    set "UNIX_PATH=!UNIX_PATH:\=/!"
    
    :: Handle drive letter (C: becomes /c)
    set "DRIVE=!UNIX_PATH:~0,1!"
    set "DRIVE=!DRIVE:A=a!"
    set "DRIVE=!DRIVE:B=b!"
    set "DRIVE=!DRIVE:C=c!"
    set "DRIVE=!DRIVE:D=d!"
    set "DRIVE=!DRIVE:E=e!"
    set "DRIVE=!DRIVE:F=f!"
    set "DRIVE=!DRIVE:G=g!"
    set "DRIVE=!DRIVE:H=h!"
    set "DRIVE=!DRIVE:I=i!"
    set "DRIVE=!DRIVE:J=j!"
    set "DRIVE=!DRIVE:K=k!"
    set "DRIVE=!DRIVE:L=l!"
    set "DRIVE=!DRIVE:M=m!"
    set "DRIVE=!DRIVE:N=n!"
    set "DRIVE=!DRIVE:O=o!"
    set "DRIVE=!DRIVE:P=p!"
    set "DRIVE=!DRIVE:Q=q!"
    set "DRIVE=!DRIVE:R=r!"
    set "DRIVE=!DRIVE:S=s!"
    set "DRIVE=!DRIVE:T=t!"
    set "DRIVE=!DRIVE:U=u!"
    set "DRIVE=!DRIVE:V=v!"
    set "DRIVE=!DRIVE:W=w!"
    set "DRIVE=!DRIVE:X=x!"
    set "DRIVE=!DRIVE:Y=y!"
    set "DRIVE=!DRIVE:Z=z!"
    
    :: Build final Unix path
    set "UNIX_PATH=/!DRIVE!!UNIX_PATH:~2!"
    
    echo Windows path: %CD%
    echo Unix path: !UNIX_PATH!
    echo.
    
    :: Get the script name
    set "SCRIPT_NAME=%~nx0"
    
    :: Start this script in Git Bash and exit current cmd window
    start "" "!GIT_BASH!" -c "cd '!UNIX_PATH!' && ./!SCRIPT_NAME!; read -p 'Press Enter to close...'"
    exit /b 0
)

:: ==================== RUNNING IN GIT BASH - MAIN SCRIPT ====================
echo ========================================
echo   CREATE RELEASE TAG FOR GITEA
echo   Running in Git Bash
echo ========================================
echo.

:: ==================== CONFIGURATION ====================
set "GITEA_URL=https://gitea.wgn.wuerth.com"
set "GITEA_OWNER=WN00224895"
set "GITEA_REPO=Datenvalidator_Batch"
set "GITEA_TOKEN_FILE=.gitea_token"
set "REMOTE_NAME=%GITEA_REPO%"
set "TAG_FILE=.currenttag"
set "RELEASE_NOTES=release.md"
set "ZIP_FILE=datenvalidator.zip"

:: ==================== CHECK FILES ====================
echo Current directory: %CD%
echo.

if not exist "%ZIP_FILE%" (
    echo [ERROR] ZIP file not found: %ZIP_FILE%
    echo Run the build script first!
    exit /b 1
)

if not exist "%RELEASE_NOTES%" (
    echo Creating default release notes...
    echo # Release Notes > "%RELEASE_NOTES%"
    echo. >> "%RELEASE_NOTES%"
    echo - Date: %DATE% %TIME% >> "%RELEASE_NOTES%"
    echo - User: %USERNAME% >> "%RELEASE_NOTES%"
    echo - Build >> "%RELEASE_NOTES%"
)

:: ==================== GITEA TOKEN ====================
set "GITEA_TOKEN="
if exist "%GITEA_TOKEN_FILE%" (
    set /p GITEA_TOKEN=<"%GITEA_TOKEN_FILE%"
    echo Token loaded
) else (
    echo.
    set /p "GITEA_TOKEN=Enter Gitea token (or press Enter to skip): "
    if not "!GITEA_TOKEN!"=="" (
        echo !GITEA_TOKEN!>"%GITEA_TOKEN_FILE%"
        attrib +h "%GITEA_TOKEN_FILE%" 2>nul
    )
)

:: ==================== TAG NUMBER ====================
if exist "%TAG_FILE%" (
    set /p TAG_NUM=<"%TAG_FILE%"
) else (
    set TAG_NUM=0
)

set /a TAG_NUM+=1
echo !TAG_NUM!>"%TAG_FILE%"

:: ==================== VERSION ====================
echo.
echo Enter version number (e.g., 5007):
set /p VERSION=

if "!VERSION!"=="" (
    set VERSION=1.0.0
)

:: Clean version
set "CLEAN_VERSION=!VERSION: =!"
set "RELEASE_TAG=v!CLEAN_VERSION!_!TAG_NUM!"

echo.
echo Creating release: !RELEASE_TAG!
echo.

:: ==================== GIT OPERATIONS ====================
:: Commit any changes
git add -A 2>nul
git commit -m "Release !RELEASE_TAG!" 2>nul

:: Create and push tag
git tag -a "!RELEASE_TAG!" -F "%RELEASE_NOTES%"
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Failed to create tag
    echo Delete existing tag with: git tag -d "!RELEASE_TAG!"
    exit /b 1
)

echo Pushing to remote...
git push %REMOTE_NAME% HEAD 2>nul
git push %REMOTE_NAME% "!RELEASE_TAG!"

:: ==================== CREATE GITEA RELEASE ====================
if not "!GITEA_TOKEN!"=="" (
    echo.
    echo Creating Gitea release...
    
    :: Create JSON
    echo { > release.json
    echo   "tag_name": "!RELEASE_TAG!", >> release.json
    echo   "name": "Release !RELEASE_TAG!", >> release.json
    echo   "body": "Release !RELEASE_TAG!", >> release.json
    echo   "draft": false, >> release.json
    echo   "prerelease": false >> release.json
    echo } >> release.json
    
    :: Create release
    curl -X POST ^
        -H "Authorization: token !GITEA_TOKEN!" ^
        -H "Content-Type: application/json" ^
        -d @release.json ^
        "!GITEA_URL!/api/v1/repos/!GITEA_OWNER!/!GITEA_REPO!/releases" ^
        -o response.json 2>nul
    
    :: Get release ID and upload ZIP
    for /f "tokens=2 delims=:," %%a in ('grep "\"id\"" response.json 2^>nul') do (
        set "RELEASE_ID=%%a"
        set "RELEASE_ID=!RELEASE_ID: =!"
        set "RELEASE_ID=!RELEASE_ID:"=!"
        
        echo Uploading ZIP file...
        curl -X POST ^
            -H "Authorization: token !GITEA_TOKEN!" ^
            -H "Content-Type: application/zip" ^
            --data-binary "@!ZIP_FILE!" ^
            "!GITEA_URL!/api/v1/repos/!GITEA_OWNER!/!GITEA_REPO!/releases/!RELEASE_ID!/assets?name=!ZIP_FILE!" 2>nul
        
        echo.
        echo Release URL: !GITEA_URL!/!GITEA_OWNER!/!GITEA_REPO!/releases/tag/!RELEASE_TAG!
    )
    
    :: Cleanup
    rm -f release.json response.json 2>nul
)

:: ==================== DONE ====================
echo.
echo ========================================
echo   RELEASE COMPLETED!
echo ========================================
echo.
echo Tag: !RELEASE_TAG!
echo.

exit /b 0