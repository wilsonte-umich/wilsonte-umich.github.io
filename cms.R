
# to run the Wilson web page Content Management System (CMS)
#   run R in a console
#   run `setwd()` to the root directory of the website repo, containing this script cms.R
#   run `source('cms.R')`

# set directories
# rootDir <- path.expand(dirname(parent.frame(2)$ofile))
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
    'yaml'
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
runApp(launch.browser = TRUE, port = 3840)
