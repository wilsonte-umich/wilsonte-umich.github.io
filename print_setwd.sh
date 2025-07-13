#!/bin/bash
# Prints the R setwd() command with the current directory in Windows format

winpath=$(cygpath -m "$PWD")
echo "setwd(\"$winpath\")"