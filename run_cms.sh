#!/bin/bash

# unlike run_cms.bat on Windows, this script is not well tested on Mac!
# suggest improvements if you use in on Mac

# Set working directory to the script's location
cd "$(dirname "$0")"

# Check if cms.R exists
if [[ ! -f "cms.R" ]]; then
    echo "Error: cms.R not found in the current directory."
    exit 1
fi

# Try to find Rscript in multiple locations
RSCRIPT_PATH=""

# First try PATH
if command -v Rscript >/dev/null 2>&1; then
    RSCRIPT_PATH=$(command -v Rscript)
fi

# Try common installation locations
if [[ -z "$RSCRIPT_PATH" ]]; then
    for version in "4.4.3"; do
        if [[ -x "$HOME/Library/R/R-${version}/bin/Rscript" ]]; then
            RSCRIPT_PATH="$HOME/Library/R/R-${version}/bin/Rscript"
            break
        fi
        if [[ -x "/usr/local/bin/R-${version}/bin/Rscript" ]]; then
            RSCRIPT_PATH="/usr/local/bin/R-${version}/bin/Rscript"
            break
        fi
    done
fi

# Try to find any R installation by searching directories
if [[ -z "$RSCRIPT_PATH" ]]; then
    for dir in "$HOME/Library/R/R-"* "/usr/local/bin/R-"*; do
        if [[ -x "$dir/bin/Rscript" ]]; then
            RSCRIPT_PATH="$dir/bin/Rscript"
            break
        fi
    done
fi

# If Rscript is not found, exit with an error
if [[ -z "$RSCRIPT_PATH" ]]; then
    echo "Error: Rscript not found. Please ensure R is installed."
    echo "Searched locations:"
    echo "- System PATH"
    echo "- $HOME/Library/R/"
    echo "- /usr/local/bin/"
    exit 1
fi

# Run the R script
echo "Using R at: $RSCRIPT_PATH"
"$RSCRIPT_PATH" cms.R

# Check if the R script ran successfully
if [[ $? -ne 0 ]]; then
    echo "Error: R script failed with error code $?"
    exit 1
fi

echo "R script executed successfully."
