@echo off
setlocal enabledelayedexpansion

:: ==================== CHANGE TO SCRIPT DIRECTORY ====================
cd /d "%~dp0"
echo Working directory: %CD%
echo.

:: ==================== CONFIGURATION ====================
set "VERSION=0.5006_fix_fix_fix"
set "MAIN_SCRIPT=main.ahk2"
set "MAIN_EXE=daten_validator_v%VERSION%.exe"
set "MAIN_ICON=main.ico"

set "OUTPUT_DIR=datenvalidator"
set "COMPILE_DIR=.gitcompile"
set "TAG_FILE=.currenttag"
set "COMPILED_BRANCH=compiled"

:: AutoHotkey v2 paths
set "AHK2_EXE=C:\Users\wn00224895\OneDrive - WGS 365\Desktop\AHK STUFF\v2\AutoHotkey64.exe"
set "AHK2_COMPILER=C:\Users\wn00224895\AppData\Local\Programs\AutoHotkey\Compiler\Ahk2Exe.exe"

:: Alternative standard locations (fallback)
set "AHK2_COMPILER_STD=%ProgramFiles%\AutoHotkey\v2\Compiler\Ahk2Exe.exe"
set "AHK2_COMPILER_ALT=%LocalAppData%\Programs\AutoHotkey\v2\Compiler\Ahk2Exe.exe"

:: Required files
set "REQUIRED_AHK2_FILES=declarations.ahk2 utility.ahk2 excel_functions.ahk2 sap_functions.ahk2 se16_selectionscreen.ahk2 sessionfix.ahk2 JSON.ahk2 sap_worker.ahk2 codewrapper.ahk2"
set "REQUIRED_OTHER_FILES=script_template.txt worker_config.ini illegals.cfg"
set "REQUIRED_EMPTY_FILES=databases.cfg rfc_destinations.cfg"

:: ==================== DISPLAY HEADER ====================
cls
echo ========================================
echo   Data Validator Build Script v%VERSION%
echo   User: %USERNAME%
echo   Date: %DATE% %TIME%
echo   Directory: %CD%
echo ========================================
echo.

:: ==================== SETUP COMPILATION DIRECTORY ====================
echo [0/9] Setting up compilation directory...
echo.

:: Check if git is available
where git >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Git is not installed or not in PATH!
    goto :error
)

:: Store main directory
set "MAIN_DIR=%CD%"

:: Check if .gitcompile exists
if not exist "%COMPILE_DIR%" (
    echo Creating .gitcompile directory for first time...
    mkdir "%COMPILE_DIR%"
    
    :: Check if we have a local datenvalidator folder to copy .git from
    if exist "%OUTPUT_DIR%\.git" (
        echo Found existing git repository in %OUTPUT_DIR%, copying...
        xcopy /E /I /H /Y "%OUTPUT_DIR%\.git" "%COMPILE_DIR%\.git" >nul 2>&1
    ) else (
        echo.
        echo =================================================
        echo  FIRST TIME SETUP REQUIRED
        echo =================================================
        echo.
        echo No git repository found. Please:
        echo 1. Log into your Gitea instance
        echo 2. Create a new repository for compiled outputs
        echo 3. Note the repository URL
        echo.
        set /p REPO_URL="Enter repository URL (e.g., https://gitea.example.com/user/repo.git): "
        
        cd "%COMPILE_DIR%"
        git init
        git remote add origin !REPO_URL!
        
        :: Create initial commit
        echo # Compiled Outputs > README.md
        git add README.md
        git commit -m "Initial commit - compiled outputs repository"
        
        :: Try to push
        echo.
        echo Attempting to push to repository...
        git push -u origin master
        if %ERRORLEVEL% neq 0 (
            echo.
            echo [WARNING] Could not push. You may need to:
            echo   1. Check your credentials
            echo   2. Create the repository on Gitea first
            echo   3. Run: git push -u origin master
            echo.
            pause
        )
        cd "%MAIN_DIR%"
    )
) else (
    echo Found existing .gitcompile directory
)


:: ==================== SYNC COMPILATION DIRECTORY ====================
echo [1/9] Syncing compilation directory...
echo.

cd "%COMPILE_DIR%"

:: Pull latest from compiled branch
echo Pulling latest compiled branch...
git pull >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo No remote compiled branch found or pull failed (may be first time)
)

cd "%MAIN_DIR%"

:: ==================== SYNC SOURCE REPOSITORY ====================
echo [2/9] Syncing source repository...
echo.

:: Git pull to get latest source changes
git branch --set-upstream-to=Datenvalidator_Batch/main main
echo Pulling latest source changes...
git pull
if %ERRORLEVEL% neq 0 (
    echo [WARNING] Git pull failed or had conflicts!
    choice /C YN /M "Continue anyway"
    if !ERRORLEVEL! neq 1 goto :error
)

:: Commit any local changes
git status --porcelain >temp_git_status.txt
set /p GIT_STATUS=<temp_git_status.txt
del temp_git_status.txt

if not "!GIT_STATUS!"=="" (
    echo Found uncommitted changes, committing...
    git add -A
    git commit -m "Auto-commit before build v%VERSION%"
    git push
)
echo.

:: ==================== CHECK PREREQUISITES ====================
echo [3/9] Checking prerequisites...
echo.

:: Find AutoHotkey v2 compiler
if exist "%AHK2_COMPILER%" (
    set "COMPILER=%AHK2_COMPILER%"
    set "AHK_BASE=%AHK2_EXE%"
    echo [OK] Found compiler at custom location
) else if exist "%AHK2_COMPILER_STD%" (
    set "COMPILER=%AHK2_COMPILER_STD%"
    set "AHK_BASE=%ProgramFiles%\AutoHotkey\v2\AutoHotkey64.exe"
    echo [OK] Found compiler at standard location
) else if exist "%AHK2_COMPILER_ALT%" (
    set "COMPILER=%AHK2_COMPILER_ALT%"
    set "AHK_BASE=%LocalAppData%\Programs\AutoHotkey\v2\AutoHotkey64.exe"
    echo [OK] Found compiler at alternative location
) else (
    echo [ERROR] AutoHotkey v2 compiler not found!
    goto :error
)

:: Check main script
if not exist "%MAIN_SCRIPT%" (
    echo [ERROR] Main script not found: %MAIN_SCRIPT%
    goto :error
)
echo [OK] Found main script: %MAIN_SCRIPT%

:: Check required files
echo.
echo Checking required files...
set "MISSING_FILES="
for %%F in (%REQUIRED_AHK2_FILES%) do (
    if exist "%%F" (
        echo [OK] Found: %%F
    ) else (
        echo [MISSING] %%F
        set "MISSING_FILES=!MISSING_FILES! %%F"
    )
)

for %%F in (%REQUIRED_OTHER_FILES%) do (
    if exist "%%F" (
        echo [OK] Found: %%F
    ) else (
        echo [MISSING] %%F
        set "MISSING_FILES=!MISSING_FILES! %%F"
    )
)

if not "!MISSING_FILES!"=="" (
    echo.
    echo [WARNING] Missing files:!MISSING_FILES!
    choice /C YN /M "Continue anyway"
    if !ERRORLEVEL! neq 1 goto :error
)

:: Check for icon
if exist "%MAIN_ICON%" (
    echo [OK] Found icon: %MAIN_ICON%
    set "MAIN_ICON_PARAM=/icon "%CD%\%MAIN_ICON%""
) else (
    echo [WARN] Icon not found: %MAIN_ICON%
    set "MAIN_ICON_PARAM="
)
echo.

:: ==================== COMPILE MAIN SCRIPT ====================
echo [4/9] Compiling main script...
echo.

set "FULL_MAIN_SCRIPT=%CD%\%MAIN_SCRIPT%"
set "FULL_MAIN_EXE=%CD%\%MAIN_EXE%"

echo Executing compiler...
if defined MAIN_ICON_PARAM (
    "%COMPILER%" /in "%FULL_MAIN_SCRIPT%" /out "%FULL_MAIN_EXE%" /base "%AHK_BASE%" %MAIN_ICON_PARAM%
) else (
    "%COMPILER%" /in "%FULL_MAIN_SCRIPT%" /out "%FULL_MAIN_EXE%" /base "%AHK_BASE%"
)

if %ERRORLEVEL% neq 0 (
    echo [ERROR] Compilation failed!
    goto :error
)

if not exist "%FULL_MAIN_EXE%" (
    echo [ERROR] Executable was not created!
    goto :error
)

for %%A in ("%FULL_MAIN_EXE%") do set "MAIN_SIZE=%%~zA"
echo [SUCCESS] Created %MAIN_EXE% (Size: %MAIN_SIZE% bytes)
echo.

:: ==================== CREATE OUTPUT IN COMPILE DIR ====================
echo [5/9] Creating output in compilation directory...
echo.

:: Clean compile directory (except .git)
cd "%COMPILE_DIR%"
for /f "tokens=*" %%i in ('dir /b /a-d 2^>nul') do (
    if not "%%i"==".git" del /Q "%%i" >nul 2>&1
)
for /f "tokens=*" %%i in ('dir /b /ad 2^>nul') do (
    if not "%%i"==".git" rmdir /S /Q "%%i" >nul 2>&1
)

:: Create logs directory
if not exist "logs" mkdir "logs"

cd "%MAIN_DIR%"

:: Copy executable
copy /Y "%FULL_MAIN_EXE%" "%COMPILE_DIR%\" >nul 2>&1
echo   + %MAIN_EXE%

:: Copy AutoHotkey runtime
copy /Y "%AHK_BASE%" "%COMPILE_DIR%\AutoHotkey64.exe" >nul 2>&1
echo   + AutoHotkey64.exe

:: Copy AHK2 files
for %%F in (%REQUIRED_AHK2_FILES%) do (
    if exist "%%F" (
        copy /Y "%%F" "%COMPILE_DIR%\" >nul 2>&1
        echo   + %%F
    )
)

:: Copy config files
for %%F in (%REQUIRED_OTHER_FILES%) do (
    if exist "%%F" (
        copy /Y "%%F" "%COMPILE_DIR%\" >nul 2>&1
        echo   + %%F
    )
)

:: Create empty config files
for %%F in (%REQUIRED_EMPTY_FILES%) do (
    type nul > "%COMPILE_DIR%\%%F"
    echo   + Created empty %%F
)

:: Create version file
(
echo %VERSION%
echo %DATE% %TIME%
echo %USERNAME%
echo %COMPUTERNAME%
) > "%COMPILE_DIR%\version.txt"
echo   + version.txt
echo.

:: ==================== CREATE ZIP ====================
echo [6/9] Creating ZIP archive...
set "ZIP_FILE=%MAIN_DIR%\%OUTPUT_DIR%.zip"
if exist "%ZIP_FILE%" del /Q "%ZIP_FILE%"

powershell -Command "Compress-Archive -Path '%COMPILE_DIR%\*' -DestinationPath '%ZIP_FILE%' -Force"
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Failed to create ZIP!
    goto :error
)
echo ZIP created: %ZIP_FILE%
echo.

:: ==================== COMMIT COMPILED FILES ====================
echo [7/9] Committing compiled files...
echo.

cd "%COMPILE_DIR%"

:: Add all files
git add -A

:: Commit
set "COMMIT_MSG=Compiled build v%VERSION% - %DATE% %TIME%"
git commit -m "%COMMIT_MSG%"

:: Push to compiled branch
git push
if %ERRORLEVEL% neq 0 (
    echo [WARNING] Push failed!
)

cd "%MAIN_DIR%"

:: ==================== UPDATE .GIT FOLDER ====================
echo [8/9] Updating git repository backup...
echo.

:: Delete old backup
if exist "%OUTPUT_DIR%\.git" (
    rmdir /S /Q "%OUTPUT_DIR%\.git"
)

:: Create output dir if needed
if not exist "%OUTPUT_DIR%" mkdir "%OUTPUT_DIR%"

:: Copy current compile .git to backup
xcopy /E /I /H /Y "%COMPILE_DIR%\.git" "%OUTPUT_DIR%\.git" >nul 2>&1
echo Git repository backed up to %OUTPUT_DIR%\.git
echo.

:: ==================== INCREMENT TAG AND CREATE RELEASE ====================
echo [9/9] Creating release...
echo.

:: Read/increment tag
if exist "%TAG_FILE%" (
    set /p TAG_NUM=<"%TAG_FILE%"
) else (
    set TAG_NUM=0
)
set /a TAG_NUM+=1
echo !TAG_NUM!>"%TAG_FILE%"

:: Commit tag file
git add "%TAG_FILE%"
git commit -m "Build tag: !TAG_NUM!"
git push

:: Clean version for tag
set "CLEAN_VERSION=%VERSION%"
set "CLEAN_VERSION=!CLEAN_VERSION: =!"
set "CLEAN_VERSION=!CLEAN_VERSION:/=!"
set "CLEAN_VERSION=!CLEAN_VERSION:\=!"
set "CLEAN_VERSION=!CLEAN_VERSION:|=!"
set "CLEAN_VERSION=!CLEAN_VERSION:?=!"
set "CLEAN_VERSION=!CLEAN_VERSION:*=!"
set "CLEAN_VERSION=!CLEAN_VERSION:"=!"
set "CLEAN_VERSION=!CLEAN_VERSION:<=!"
set "CLEAN_VERSION=!CLEAN_VERSION:>=!"
set "CLEAN_VERSION=!CLEAN_VERSION:~0,30!"

set "RELEASE_TAG=v!CLEAN_VERSION!_!TAG_NUM!"

:: Try GitHub CLI
where gh >nul 2>&1
if %ERRORLEVEL% equ 0 (
    echo Creating GitHub release: !RELEASE_TAG!
    
    (
    echo Build: %VERSION%
    echo Number: !TAG_NUM!
    echo Date: %DATE% %TIME%
    ) > release_notes.txt
    
    gh release create "!RELEASE_TAG!" "%ZIP_FILE%" ^
        --title "Release !RELEASE_TAG!" ^
        --notes-file release_notes.txt
    
    del release_notes.txt
) else (
    echo GitHub CLI not found. Manual release tag: !RELEASE_TAG!
)

:: ==================== SUCCESS ====================
echo.
echo ========================================
echo   BUILD SUCCESSFUL!
echo ========================================
echo.
echo Build Number: !TAG_NUM!
echo Release Tag: !RELEASE_TAG!
echo Compiled to: %COMPILE_DIR%
echo ZIP File: %ZIP_FILE%
echo.

choice /C YN /T 10 /D N /M "Open compilation directory"
if %ERRORLEVEL% equ 1 (
    start "" explorer "%CD%\%COMPILE_DIR%"
)

exit /b 0

:: ==================== ERROR HANDLER ====================
:error
echo.
echo ========================================
echo   BUILD FAILED!
echo ========================================
echo.
exit /b 1