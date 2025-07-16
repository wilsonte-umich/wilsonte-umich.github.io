@echo off

REM Set working directory to the script location
cd /d "%~dp0"

REM Check if cms.R exists
if not exist "cms.R" (
    echo Error: cms.R not found in current directory
    pause
    exit /b 1
)

REM Try to find Rscript.exe in multiple locations
set "RSCRIPT_PATH="

REM First try PATH
where Rscript.exe >nul 2>&1
if %errorlevel% equ 0 (
    set "RSCRIPT_PATH=Rscript.exe"
    goto :run_script
)

REM Try common installation locations
for %%v in (4.4.3) do (
    if exist "%USERPROFILE%\AppData\Local\Programs\R\R-%%v\bin\x64\Rscript.exe" (
        set "RSCRIPT_PATH=%USERPROFILE%\AppData\Local\Programs\R\R-%%v\bin\x64\Rscript.exe"
        goto :run_script
    )
    if exist "C:\Program Files\R\R-%%v\bin\x64\Rscript.exe" (
        set "RSCRIPT_PATH=C:\Program Files\R\R-%%v\bin\x64\Rscript.exe"
        goto :run_script
    )
)

REM Try to find any R installation by searching directories
for /d %%d in ("%USERPROFILE%\AppData\Local\Programs\R\R-*") do (
    if exist "%%d\bin\x64\Rscript.exe" (
        set "RSCRIPT_PATH=%%d\bin\x64\Rscript.exe"
        goto :run_script
    )
)

for /d %%d in ("C:\Program Files\R\R-*") do (
    if exist "%%d\bin\x64\Rscript.exe" (
        set "RSCRIPT_PATH=%%d\bin\x64\Rscript.exe"
        goto :run_script
    )
)

REM If we get here, R was not found
echo Error: Rscript.exe not found. Please ensure R is installed.
echo Searched locations:
echo - System PATH
echo - %USERPROFILE%\AppData\Local\Programs\R\
echo - C:\Program Files\R\
pause
exit /b 1

:run_script
echo Using R at: %RSCRIPT_PATH%
"%RSCRIPT_PATH%" cms.R

REM Check if R script ran successfully
if %errorlevel% neq 0 (
    echo Error: R script failed with error code %errorlevel%
)

pause
