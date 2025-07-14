# this script runs on Great Lakes to start the CMS app
# it is called by scripts run_remote_cms.sh/bat

# Function to cleanup R process on exit
cleanup() {
    echo "Cleaning up R process..."
    if [ ! -z "$R_PID" ]; then
        kill $R_PID 2>/dev/null
        wait $R_PID 2>/dev/null
        echo "R process terminated."
    fi
    exit 0
}

# Set trap to catch signals and cleanup
# SIGHUP (1) - terminal hangup (SSH disconnect)
# SIGINT (2) - interrupt (Ctrl+C)  
# SIGTERM (15) - termination signal
trap cleanup HUP INT TERM

module load R/4.4.3
cd /nfs/turbo/path-wilsonte-turbo/website/wilsonte-umich.github.io

# Start R script in background and capture its PID
Rscript cms.R &
R_PID=$!

echo "R process started with PID: $R_PID"
echo "Press Ctrl+C to stop or script will terminate when SSH connection drops"

# Wait for the R process to complete
wait $R_PID
