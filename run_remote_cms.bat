@echo off
REM Prompt for username
set /p USERNAME=Enter your Great Lakes username: 

REM Set other variables
set SERVER_IP=greatlakes.arc-ts.umich.edu
set REMOTE_SCRIPT=/nfs/turbo/path-wilsonte-turbo/website/cms.sh
set LOCAL_PORT=3840
set REMOTE_PORT=3840

REM Start SSH with port forwarding and run the R script
ssh -L %LOCAL_PORT%:localhost:%REMOTE_PORT% %USERNAME%@%SERVER_IP% "bash %REMOTE_SCRIPT%"

REM After running, access the Shiny app at http://localhost:3840
pause
