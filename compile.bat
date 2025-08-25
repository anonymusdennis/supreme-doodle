@echo off
setlocal enabledelayedexpansion

:: ==================== CHANGE TO SCRIPT DIRECTORY ====================
:: This ensures all relative paths work correctly
cd /d "%~dp0"
echo Working directory: %CD%
echo.

:: ==================== CONFIGURATION ====================
set "VERSION=0.5006_fix_fix_fix"
set "MAIN_SCRIPT=main.ahk2"
set "MAIN_EXE=daten_validator_v%VERSION%.exe"
set "MAIN_ICON=main.ico"

set "OUTPUT_DIR=datenvalidator"
set "TAG_FILE=.currenttag"

:: AutoHotkey v2 paths - WITH SPACES (properly quoted)
:: Update these paths to match your system
set "AHK2_EXE=C:\Users\wn00224895\OneDrive - WGS 365\Desktop\AHK STUFF\v2\AutoHotkey64.exe"
set "AHK2_COMPILER=C:\Users\wn00224895\AppData\Local\Programs\AutoHotkey\v2\Compiler\Ahk2Exe.exe"

:: Alternative standard locations (fallback)
set "AHK2_COMPILER_STD=%ProgramFiles%\AutoHotkey\v2\Compiler\Ahk2Exe.exe"
set "AHK2_COMPILER_ALT=%LocalAppData%\Programs\AutoHotkey\v2\Compiler\Ahk2Exe.exe"

:: Required AHK2 files to copy
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

:: ==================== GIT OPERATIONS - PULL AND PUSH ====================
echo [0/8] Performing Git operations...
echo.

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

:: Git pull to get latest changes
echo Pulling latest changes from remote...
git pull
if %ERRORLEVEL% neq 0 (
    echo [WARNING] Git pull failed or had conflicts!
    echo Please resolve conflicts manually and run again.
    choice /C YN /M "Continue anyway"
    if !ERRORLEVEL! neq 1 goto :error
)

:: Git add and commit any local changes
echo.
echo Checking for uncommitted changes...
git status --porcelain >temp_git_status.txt
set /p GIT_STATUS=<temp_git_status.txt
del temp_git_status.txt

if not "!GIT_STATUS!"=="" (
    echo Found uncommitted changes, committing...
    git add -A
    git commit -m "Auto-commit before build v%VERSION%"
    
    :: Push changes
    echo Pushing changes to remote...
    git push
    if %ERRORLEVEL% neq 0 (
        echo [WARNING] Git push failed!
        choice /C YN /M "Continue anyway"
        if !ERRORLEVEL! neq 1 goto :error
    )
) else (
    echo No uncommitted changes found.
)
echo.

:: ==================== CHECK PREREQUISITES ====================
echo [1/8] Checking prerequisites...
echo.

:: Find AutoHotkey v2 compiler - check custom path first
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
    echo.
    echo Checked locations:
    echo   1. "%AHK2_COMPILER%"
    echo   2. "%AHK2_COMPILER_STD%"
    echo   3. "%AHK2_COMPILER_ALT%"
    echo.
    echo Please update the AHK2_COMPILER path in this script.
    goto :error
)

echo Compiler: "%COMPILER%"
echo Base EXE: "%AHK_BASE%"
echo.

:: Verify compiler and runtime exist
if not exist "%COMPILER%" (
    echo [ERROR] Compiler file does not exist at specified path!
    goto :error
)

if not exist "%AHK_BASE%" (
    echo [ERROR] AutoHotkey runtime not found at: "%AHK_BASE%"
    echo Please check the AHK2_EXE path in this script.
    goto :error
)

:: Check if main source file exists
echo Checking source files in: %CD%
echo.

if not exist "%CD%\%MAIN_SCRIPT%" (
    echo [ERROR] Main script not found: %CD%\%MAIN_SCRIPT%
    echo.
    echo Please ensure %MAIN_SCRIPT% is in the same directory as this batch file.
    goto :error
)
echo [OK] Found main script: %MAIN_SCRIPT%

:: Check for required AHK2 files
echo.
echo Checking required AHK2 files...
set "MISSING_FILES="
for %%F in (%REQUIRED_AHK2_FILES%) do (
    if exist "%CD%\%%F" (
        echo [OK] Found: %%F
    ) else (
        echo [MISSING] %%F
        set "MISSING_FILES=!MISSING_FILES! %%F"
    )
)
:: Repeat for other required files
for %%F in (%REQUIRED_OTHER_FILES%) do (
    if exist "%CD%\%%F" (
        echo [OK] Found: %%F
    ) else (
        echo [MISSING] %%F
        set "MISSING_FILES=!MISSING_FILES! %%F"
    )
)

if not "!MISSING_FILES!"=="" (
    echo.
    echo [WARNING] Missing files:!MISSING_FILES!
    echo These files are required for the application to work properly.
    echo.
    choice /C YN /M "Continue anyway"
    if !ERRORLEVEL! neq 1 (
        goto :error
    )
)

:: Check for icon file (optional)
if exist "%CD%\%MAIN_ICON%" (
    echo [OK] Found icon: %MAIN_ICON%
    set "MAIN_ICON_PARAM=/icon "%CD%\%MAIN_ICON%""
) else (
    echo [WARN] Icon not found: %MAIN_ICON% - will compile without icon
    set "MAIN_ICON_PARAM="
)

echo.

:: ==================== COMPILE MAIN SCRIPT ====================
echo [2/8] Compiling main script...
echo.

:: Use FULL PATHS for everything to avoid issues
set "FULL_MAIN_SCRIPT=%CD%\%MAIN_SCRIPT%"
set "FULL_MAIN_EXE=%CD%\%MAIN_EXE%"

echo Executing command:
if defined MAIN_ICON_PARAM (
    echo "%COMPILER%" /in "%FULL_MAIN_SCRIPT%" /out "%FULL_MAIN_EXE%" /base "%AHK_BASE%" %MAIN_ICON_PARAM%
    echo.
    "%COMPILER%" /in "%FULL_MAIN_SCRIPT%" /out "%FULL_MAIN_EXE%" /base "%AHK_BASE%" %MAIN_ICON_PARAM%
) else (
    echo "%COMPILER%" /in "%FULL_MAIN_SCRIPT%" /out "%FULL_MAIN_EXE%" /base "%AHK_BASE%"
    echo.
    "%COMPILER%" /in "%FULL_MAIN_SCRIPT%" /out "%FULL_MAIN_EXE%" /base "%AHK_BASE%"
)

:: Check if compilation was successful
if %ERRORLEVEL% neq 0 (
    echo.
    echo [ERROR] Compilation failed with error code: %ERRORLEVEL%
    echo.
    echo Possible causes:
    echo   1. Script has syntax errors
    echo   2. Compiler path is incorrect
    echo   3. Insufficient permissions
    echo   4. Antivirus blocking the compiler
    goto :error
)

:: Verify the executable was created
timeout /t 2 /nobreak >nul
if not exist "%FULL_MAIN_EXE%" (
    echo [ERROR] Main executable was not created!
    echo Expected location: %FULL_MAIN_EXE%
    goto :error
)

:: Get file size
for %%A in ("%FULL_MAIN_EXE%") do set "MAIN_SIZE=%%~zA"
echo [SUCCESS] Created %MAIN_EXE% (Size: %MAIN_SIZE% bytes)
echo.

:: ==================== CREATE OUTPUT DIRECTORY ====================
echo [3/8] Creating output directory structure...
::delete first 
if exist "%OUTPUT_DIR%" (
    echo Deleting existing output directory: %OUTPUT_DIR%\
    rmdir /S /Q "%OUTPUT_DIR%"
)

if not exist "%OUTPUT_DIR%" (
    mkdir "%OUTPUT_DIR%"
    echo Created: %OUTPUT_DIR%\
)

if not exist "%OUTPUT_DIR%\logs" (
    mkdir "%OUTPUT_DIR%\logs"
    echo Created: %OUTPUT_DIR%\logs\
)
echo.

:: ==================== COPY MAIN EXECUTABLE ====================
echo [4/8] Deploying main executable...

copy /Y "%FULL_MAIN_EXE%" "%OUTPUT_DIR%\" >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Failed to copy %MAIN_EXE%
    goto :error
)
echo   + %MAIN_EXE%

:: COPY AHK_BASE executable to current and output directory
copy /Y "%AHK_BASE%" "%CD%\" >nul 2>&1
copy /Y "%AHK_BASE%" "%OUTPUT_DIR%\" >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Failed to copy AutoHotkey runtime executable!
    goto :error
)
echo   + AutoHotkey64.exe
echo.

:: ==================== COPY AHK2 FILES ====================
echo [5/8] Copying script files and configurations...
echo.

echo Copying AHK2 script files...
set "AHK2_COPIED=0"
for %%F in (%REQUIRED_AHK2_FILES%) do (
    if exist "%CD%\%%F" (
        copy /Y "%CD%\%%F" "%OUTPUT_DIR%\" >nul 2>&1
        if !ERRORLEVEL! equ 0 (
            echo   + %%F
            set /a AHK2_COPIED+=1
        ) else (
            echo   [ERROR] Failed to copy %%F
        )
    )
)
echo Total AHK2 files copied: !AHK2_COPIED!

:: ==================== COPY CONFIGURATION FILES ====================
echo.
echo Copying configuration files...
set "CONFIG_COPIED=0"
for %%F in (%REQUIRED_OTHER_FILES%) do (
    if exist "%CD%\%%F" (
        copy /Y "%CD%\%%F" "%OUTPUT_DIR%\" >nul 2>&1
        if !ERRORLEVEL! equ 0 (
            echo   + %%F
            set /a CONFIG_COPIED+=1
        ) else (
            echo   [ERROR] Failed to copy %%F
        )
    )
)
::create empty config files
for %%F in (%REQUIRED_EMPTY_FILES%) do (
    if not exist "%OUTPUT_DIR%\%%F" (
        ::create file without echo 
        type nul > "%OUTPUT_DIR%\%%F"
        echo   + Created empty %%F
        set /a CONFIG_COPIED+=1
    )
)

:: ==================== CREATE VERSION FILE ====================
(
echo %VERSION%
echo %DATE% %TIME%
echo %USERNAME%
echo %COMPUTERNAME%
) > "%OUTPUT_DIR%\version.txt"
echo   + version.txt
echo.

:: ==================== CREATE ZIP FILE ====================
echo [6/8] Creating ZIP archive of the output directory...
set "ZIP_FILE=%OUTPUT_DIR%.zip"
if exist "%ZIP_FILE%" (
    del /Q "%ZIP_FILE%"
)
echo Creating ZIP file: %ZIP_FILE%
powershell -Command "Compress-Archive -Path '%OUTPUT_DIR%\*' -DestinationPath '%ZIP_FILE%' -Force"
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Failed to create ZIP archive!
    goto :error
)
echo ZIP archive created successfully: %ZIP_FILE%
echo.

:: ==================== UPLOAD TO COMPILED BRANCH ====================
echo [7/8] Uploading compiled files to 'compiled' branch...
echo.

:: Save current branch
for /f "tokens=*" %%i in ('git rev-parse --abbrev-ref HEAD') do set CURRENT_BRANCH=%%i
echo Current branch: %CURRENT_BRANCH%

:: Check if compiled branch exists
git show-ref --verify --quiet refs/heads/compiled
if %ERRORLEVEL% neq 0 (
    echo Creating 'compiled' branch...
    git checkout --orphan compiled
    git rm -rf .
) else (
    echo Switching to 'compiled' branch...
    git checkout compiled
)

:: Clean the compiled branch (remove all files)
echo Cleaning compiled branch...
git rm -rf . >nul 2>&1

:: Copy output directory contents to current directory
echo Copying compiled files...
xcopy /E /I /Y "%OUTPUT_DIR%\*" . >nul 2>&1

:: Add all files to git
git add -A

:: Commit with timestamp
set "COMMIT_MSG=Compiled build v%VERSION% - %DATE% %TIME%"
git commit -m "%COMMIT_MSG%"

:: Push to compiled branch
echo Pushing to remote 'compiled' branch...
git push origin compiled --force
if %ERRORLEVEL% neq 0 (
    echo [WARNING] Failed to push to compiled branch!
)

:: Switch back to original branch
echo Switching back to %CURRENT_BRANCH% branch...
git checkout %CURRENT_BRANCH%

:: Clean up the files we copied
for %%F in (%REQUIRED_AHK2_FILES% %REQUIRED_OTHER_FILES% %REQUIRED_EMPTY_FILES%) do (
    if exist "%%F" del /Q "%%F" >nul 2>&1
)
if exist "AutoHotkey64.exe" del /Q "AutoHotkey64.exe" >nul 2>&1
if exist "%MAIN_EXE%" del /Q "%MAIN_EXE%" >nul 2>&1
if exist "version.txt" del /Q "version.txt" >nul 2>&1
if exist "logs" rmdir /S /Q "logs" >nul 2>&1

echo.

:: ==================== INCREMENT TAG NUMBER ====================
echo [8/8] Creating GitHub release...
echo.

:: Read current tag number or initialize
if exist "%TAG_FILE%" (
    set /p TAG_NUM=<"%TAG_FILE%"
) else (
    set TAG_NUM=0
)

:: Increment tag number
set /a TAG_NUM+=1
echo !TAG_NUM!>"%TAG_FILE%"
echo Updated tag number to: !TAG_NUM!

:: Git add and commit the tag file
git add "%TAG_FILE%"
git commit -m "Increment build tag to !TAG_NUM!"
git push

:: ==================== CREATE GITHUB RELEASE ====================
:: Clean version string (remove illegal characters, limit length)
set "CLEAN_VERSION=%VERSION%"
:: Remove spaces and special characters
set "CLEAN_VERSION=!CLEAN_VERSION: =!"
set "CLEAN_VERSION=!CLEAN_VERSION:/=!"
set "CLEAN_VERSION=!CLEAN_VERSION:\=!"
set "CLEAN_VERSION=!CLEAN_VERSION:|=!"
set "CLEAN_VERSION=!CLEAN_VERSION:?=!"
set "CLEAN_VERSION=!CLEAN_VERSION:*=!"
set "CLEAN_VERSION=!CLEAN_VERSION:"=!"
set "CLEAN_VERSION=!CLEAN_VERSION:<=!"
set "CLEAN_VERSION=!CLEAN_VERSION:>=!"

:: Limit to 30 characters to ensure tag isn't too long
set "CLEAN_VERSION=!CLEAN_VERSION:~0,30!"

:: Create release tag
set "RELEASE_TAG=v!CLEAN_VERSION!_!TAG_NUM!"
echo Creating release with tag: !RELEASE_TAG!

:: Check if gh CLI is available
where gh >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [WARNING] GitHub CLI (gh) is not installed!
    echo Cannot create automatic release.
    echo.
    echo To install GitHub CLI:
    echo   1. Download from: https://cli.github.com/
    echo   2. Run: gh auth login
    echo.
    echo Manual release info:
    echo   Tag: !RELEASE_TAG!
    echo   File: %ZIP_FILE%
) else (
    :: Create release with gh CLI
    echo Creating GitHub release...
    
    :: Create release notes
    (
    echo Build Information:
    echo - Version: %VERSION%
    echo - Build Number: !TAG_NUM!
    echo - Date: %DATE% %TIME%
    echo - User: %USERNAME%
    echo - Machine: %COMPUTERNAME%
    echo.
    echo Files included:
    echo - Main Application: %MAIN_EXE%
    echo - AutoHotkey Runtime: AutoHotkey64.exe
    echo - Worker Scripts: !AHK2_COPIED! files
    echo - Config Files: !CONFIG_COPIED! files
    ) > release_notes.txt
    
    :: Create the release
    gh release create "!RELEASE_TAG!" "%ZIP_FILE%" ^
        --title "Release !RELEASE_TAG!" ^
        --notes-file release_notes.txt ^
        --target %CURRENT_BRANCH%
    
    if %ERRORLEVEL% equ 0 (
        echo [SUCCESS] GitHub release created: !RELEASE_TAG!
        echo Release URL: https://github.com/{owner}/{repo}/releases/tag/!RELEASE_TAG!
    ) else (
        echo [WARNING] Failed to create GitHub release
        echo You can manually create it with tag: !RELEASE_TAG!
    )
    
    :: Clean up release notes
    if exist release_notes.txt del /Q release_notes.txt
)

echo.

:: ==================== SUCCESS ====================
echo.
echo ========================================
echo   BUILD SUCCESSFUL!
echo ========================================
echo.
echo Deployment: %CD%\%OUTPUT_DIR%
echo.
echo Summary:
echo --------
echo   Main Application: %MAIN_EXE% (!MAIN_SIZE! bytes)
echo   AutoHotkey Runtime: AutoHotkey64.exe
echo   Worker Scripts: !AHK2_COPIED! files
echo   Config Files: !CONFIG_COPIED! files
echo   Build Number: !TAG_NUM!
echo   Release Tag: !RELEASE_TAG!
echo.
echo Git Operations:
echo   - Changes pulled from remote
echo   - Compiled files pushed to 'compiled' branch
echo   - Release created with tag: !RELEASE_TAG!
echo.
echo The package is self-contained and ready for deployment.
echo AutoHotkey does NOT need to be installed on target systems.
echo.

:: List all files
echo Package contents:
echo -----------------
dir /B "%OUTPUT_DIR%\*.exe" "%OUTPUT_DIR%\*.ahk2" "%OUTPUT_DIR%\*.cfg" "%OUTPUT_DIR%\*.txt" "%OUTPUT_DIR%\*.bat" 2>nul | sort
echo.

:: Open folder
choice /C YN /T 10 /D N /M "Open output directory"
if %ERRORLEVEL% equ 1 (
    start "" explorer "%CD%\%OUTPUT_DIR%"
)

echo.
echo Deployment package ready at: %OUTPUT_DIR%\
echo ZIP file ready at: %ZIP_FILE%
echo GitHub Release: !RELEASE_TAG!
exit /b 0

:: ==================== ERROR HANDLER ====================
:error
echo.
echo ========================================
echo   BUILD FAILED!
echo ========================================
echo.
echo Please check the error messages above.
echo.
echo Requirements checklist:
echo   [ ] Git installed and configured
echo   [ ] GitHub CLI (gh) installed (optional, for releases)
echo   [ ] main.ahk2 exists
echo   [ ] All dependency .ahk2 files exist
echo   [ ] AutoHotkey v2 compiler is installed
echo   [ ] AutoHotkey64.exe is accessible
echo   [ ] No antivirus blocking
echo.
exit /b 1