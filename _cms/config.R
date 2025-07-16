# type conversion lists
Collections <- list(
    event       = 'events',
    funding     = 'funding',
    post        = 'newsfeed',
    person      = 'people',
    project     = 'projects',
    publication = 'publications',
    resource    = 'resources'
)
ItemTypes <- list(
    events       = 'event',
    funding      = 'funding',
    newsfeed     = 'post',
    people       = 'person',
    projects     = 'project',
    publications = 'publication',
    resources    = 'resource'
)
DataTypes <- c('events', 'funding', 'people', 'publications', 'resources') # found in _data, MAY have item markdown files
ContentTypes <- c('newsfeed', 'projects') # NOT found in _data, always have a markdown file

# help enforce a consistent sorting and grouping of badges in UI
sortItemBadges <- function(badgesIn){
    if(is.null(badgesIn)) return(badgesIn)
    unname( unlist( lapply(ItemTypes, function(itemType) sort(badgesIn[startsWith(badgesIn, itemType)])) ) )
}
sortAllBadges <- function(cfg){
    for(collection in names(cfg)){
        if(length(cfg[[collection]]) > 0){
            for(i in seq_along(cfg[[collection]])){
                cfg[[collection]][[i]]$badges <- sortItemBadges(cfg[[collection]][[i]]$badges)
            }
        }
    }
    cfg
}

# load and save the site's configuration data files
# List of 9
#  $ people        :List of 3
#   ..$ :List of 9
#   .. ..$ id     : chr "John_Doe"
loadSiteConfig <- function(){
    message(paste('loading site configuration', rootDir))
    cfg <- list()

    # load _data files
    for(type in DataTypes) cfg[[type]] <- read_yaml(data_yaml_file(type))

    # load _content files
    for(type in ContentTypes){
        cfg[[type]] <- list()
        files <- list.files(paste0(rootDir, '/', 'content/_', type),  full.names = TRUE)
        for(file in files){
            if(!endsWith(file, "_README") && !endsWith(file, "_archive")){
                id <- rev(strsplit(file, '/')[[1]])[1]
                id <- strsplit(id, '\\.')[[1]][1]
                x <- slurpFile(file)
                x <- gsub('\r', '', x)
                x <- strsplit(x, "---\n")[[1]]
                cfg[[type]][[id]] <- read_yaml(text = paste0("---\n", x[2]))
                cfg[[type]][[id]]$id <- id
            }
        }
    }

    # sort existing badges
    cfg <- sortAllBadges(cfg)

    # extract all known badges
    cfg$allowedBadges <- unname(unlist( lapply(c(ContentTypes, DataTypes), function(type){
        lapply(cfg[[type]], function(x){
            paste0(ItemTypes[[type]], '=', x$id)
        })
    }) ))

    cfg$declaredBadges <- unname(unlist( lapply(names(ItemTypes), function(type){
        lapply(cfg[[type]], function(x) {
            for(badge in x$badges){
                if(!(badge %in% cfg$allowedBadges)) {
                    print("!!! BAD BADGE !!!")
                    print(paste("source =", type, x$id))
                    print(paste("unknown badge = ", badge))
                    message()
                }
            }
            x$badges
        })
    }) ))

    # return the results
    cfg
}

# item editing UI
edit_input_name <- function(edit_prefix, suffix){
    paste(edit_prefix, suffix, sep = "_")
}
item_edit_ui <- function(type, edit_prefix, callback){
    cfg <- config()
    data_id <- input[[edit_input_name(edit_prefix, "id")]]
    req(cfg, data_id)
    i <- which(sapply(cfg[[type]], function(x) x$id == data_id))
    req(length(i) == 1)
    item <- cfg[[type]][[i]]
    tagList(
        fluidRow(
            style = "margin: 10px;",
            column(
                width = 4,
                offset = 4,
                bsButton(edit_input_name(edit_prefix, "save"), "Save Item", style = "success", width = "100%")
            )
        ),
        callback(item),
        fluidRow(
            style = "margin: 10px;",
            column(
                width = 4,
                offset = 4,
                bsButton(edit_input_name(edit_prefix, "delete"), "Delete Item", style = "danger", width = "100%")
            )
        )
    )
}
