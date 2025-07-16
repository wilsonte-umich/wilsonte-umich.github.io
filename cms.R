
# to run the Wilson web page Content Management System (CMS)
#   double-click file `run_cms.bat` from your Windows Explorer
#   point your web browser to `https://localhost:8000`

# set directories
rootDir <- getwd()
setwd(rootDir)
setwd('_cms')

# use a dedicated R library
lib.loc <- file.path(rootDir, '_cms', 'lib') 
if(!dir.exists(lib.loc)) dir.create(lib.loc)
.libPaths(c(lib.loc, .libPaths()))

# load packages, install if missing
packages <- c(
    'rlang',
    'Rcpp',
    'shiny',
    'shinydashboard',
    'shinyTree',
    'shinyjs',
    'magick',
    'yaml',
    'sortable',
    'shinyBS',
    'shinyalert',
    'shinyAce'
)
package.check <- lapply(
    packages,
    function(x){
        message(paste('checking package:', x))
        if (!require(x, character.only = TRUE, lib.loc = lib.loc)){
            message(paste('installing package:', x))
            install.packages(
                x, 
                dependencies = TRUE, 
                lib = lib.loc, 
                repos = 'https://repo.miserver.it.umich.edu/cran/'
            )
            library(x, character.only = TRUE, lib.loc = lib.loc)
        }
    }
)

# run the Shiny app
message("")
message("launch the following URL in a web browser:")
message("")
message("https://localhost:8000")
message("")
runApp(launch.browser = FALSE, port = 8000)
