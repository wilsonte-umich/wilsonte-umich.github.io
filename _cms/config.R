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
                cfg[[type]][[id]]$content <- x[3]
            }
        }
        cfg[[type]] <- if(type == "newsfeed"){
            cfg[[type]][order(sapply(cfg[[type]], function(x) x$date), decreasing = TRUE)]
        } else if(type == "projects"){
            cfg[[type]][order(sapply(cfg[[type]], function(x) x$order))]
        }
    }

    # sort existing badges
    cfg <- sortAllBadges(cfg)

    # check the integrity of all claimed badges and remove those that are out of date
    allowedBadges <- unname(unlist( lapply(c(ContentTypes, DataTypes), function(type){
        lapply(cfg[[type]], function(x){
            paste0(ItemTypes[[type]], '=', x$id)
        })
    }) ))
    declaredBadges <- unname(unlist( lapply(names(ItemTypes), function(type){
        lapply(cfg[[type]], function(item) {
            if(!is.null(item$badges)) for(badge in item$badges){
                if(!(badge %in% allowedBadges)) {
                    print("!!! BAD BADGE !!!")
                    print(paste("source =", type, item$id))
                    print(paste("unknown badge = ", badge))
                    cfg <- changeItemBadge(cfg, type, item, badge, remove = TRUE)
                    message()
                }
            }
            item$badges
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

# confirm new item addition of either item type
add_item_alert <- function(singular, placeholder, callback){
    shinyalert(
        title = paste("Add New", singular),
        type = "input",
        showCancelButton = TRUE,
        inputType = "text",
        inputValue = "",
        inputPlaceholder = placeholder,
        confirmButtonText = paste("Add", singular),
        confirmButtonCol = "#4CA63C",
        callbackR = function(entry){
            req(!is.logical(entry))
            entry <- trimws(entry)
            req(entry)
            id <- gsub("  ", " ", entry)
            id <- gsub(" ", "_", id)
            callback(id, entry)
        },
        size = "s"
    )
}

# delete a data item of either item type
show_delete_alert <- function(type, data_id_name, archive = FALSE){
    cfg <- config()
    data_id <- input[[data_id_name]]
    req(cfg, data_id)
    shinyalert(
        title = "Delete Item?",
        text = paste(
            "Are you sure you want to delete", data_id, 
            "? This action cannot be undone (you MAY be able to recover it from archived YAML files)."
        ),
        type = "warning",
        showCancelButton = TRUE,
        confirmButtonCol = "#4CA63C",
        callbackR = function(confirmed){
            req(confirmed)
            if(type %in% DataTypes) {
                i <- which(sapply(cfg[[type]], function(x) x$id == data_id))
                req(length(i) == 1)
                cfg[[type]] <- cfg[[type]][-i]
                write_data_yaml(cfg, type)
            } else {
                file <- data_markdown_file(type, cfg[[type]][[data_id]], archive = archive)
                unlink(file, force = TRUE)
                cfg[[type]][[data_id]] <- NULL
            }
            config(cfg)
            shinyjs::runjs(paste0("Shiny.onInputChange('", data_id_name, "', 'CLEAR_ITEM')"))
        }
    )
}
