@echo off

REM Set working directory to the script location
cd /d "%~dp0"

REM Check if cms.R exists
if not exist "cms.R" (
    echo Error: cms.R not found in current directory
    pause
    exit /b 1
)

REM Run the R script
C:\Users\wilsonte\AppData\Local\Programs\R\R-4.4.3\bin\x64\Rscript.exe cms.R

REM Check if R script ran successfully
if %errorlevel% neq 0 (
    echo Error: R script failed with error code %errorlevel%
)

pause