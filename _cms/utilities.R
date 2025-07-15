# general support utilities

# read an entire text file
slurpFile <- function(fileName) readChar(fileName, file.info(fileName)$size)

# missing value handling
is.absent <- function(x) is.null(x) || is.na(x[1])
naToNull <- function(x) if(is.na(x)) NULL else x
