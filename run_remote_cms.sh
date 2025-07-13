#!/bin/bash
# filepath: run_remote_cms.sh

# Prompt for username
read -p "Enter your Great Lakes username: " USERNAME

# Set other variables
SERVER_IP="greatlakes.arc-ts.umich.edu"
REMOTE_SCRIPT="/nfs/turbo/path-wilsonte-turbo/website/wilsonte-umich.github.io/cms.sh"
LOCAL_PORT=3840
REMOTE_PORT=3840

# Start SSH with port forwarding and run the script
ssh -L ${LOCAL_PORT}:localhost:${REMOTE_PORT} ${USERNAME}@${SERVER_IP} "bash ${REMOTE_SCRIPT}"

# After running, access the app at http://localhost:3840
echo "Press any key to continue..."
read -n 1 -s
