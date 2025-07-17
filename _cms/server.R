# main CMS server function
server <- function(input, output, session) { 
    source('utilities.R', local = TRUE)

    # load all site data
    source('config.R', local = TRUE)
    source('dataTypes.R', local = TRUE)
    source('contentTypes.R', local = TRUE)
    # config <- reactiveVal( loadSiteConfig() )

    # load the content tab servers
    source('site.R',      local = TRUE)
    source('events.R',    local = TRUE)
    source('funding.R',   local = TRUE)
    source('people.R',    local = TRUE)
    source('resources.R', local = TRUE)
    source('projects.R',  local = TRUE)
    source('newsfeed.R',  local = TRUE)

    # load the special tab functions for handling badge link, image processing and PubMed import
    source('badges.R',       local = TRUE)
    source('images.R',       local = TRUE)
    source('importPubMed.R', local = TRUE)
    config <- reactiveVal( loadSiteConfig() )
    # checkAllBadges()
}
