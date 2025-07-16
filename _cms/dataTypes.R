# functions to support DataTypes stored in _data YAML files

# parse data/content file paths
data_yaml_file <- function(type, archive = FALSE){
    if(archive) {
        file.path(rootDir, '_data', '_archive', paste0(type, '-', Sys.Date(), '.yml'))
    } else {
        file.path(rootDir, '_data',             paste0(type,                  '.yml'))
    }
}

# write a DataType to a YAML file
write_data_yaml <- function(cfg, type){# cfg assumed to hold the updated data
    req(type %in% DataTypes)
    main_file    <- data_yaml_file(type, archive = FALSE)
    archive_file <- data_yaml_file(type, archive = TRUE)
    file.copy(main_file, archive_file, overwrite = FALSE)
    write_yaml(cfg[[type]], main_file)
}

# reorder the entries in a DataType yaml file and save it
reorder_data_yaml <- function(type, callback){
    cfg <- config()
    req(cfg)
    req(type %in% DataTypes)
    ids_in <- sapply(cfg[[type]], function(x) x$id)
    req(ids_in)
    new <- callback(cfg)
    if(!identical(ids_in, sapply(new, function(x) x$id))){
        cfg[[type]] <- new
        write_data_yaml(cfg, type)
        config(cfg)
    }
}

# add a new item to a DataType yaml file
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
add_data_yaml_item <- function(type, item){
    cfg <- config()
    req(cfg)
    req(type %in% DataTypes)
    i <- which(sapply(cfg[[type]], function(x) x$id == item$id))
    if(length(i) > 0){
        shinyalert(
            title = "Duplicate Item ID",
            text = paste("The item ID '", item$id, "' is already in use. Cannot add the new item."),
            type = "error",
            showCancelButton = FALSE,
            confirmButtonCol = "#4CA63C"
        )
    } else {
        cfg[[type]] <- c(cfg[[type]], list(item))
        write_data_yaml(cfg, type)
        config(cfg)
    }
}

# update a DataType item
update_data_yaml <- function(type, data_id_name, callback = NULL){
    cfg <- config()
    data_id <- input[[data_id_name]]
    req(cfg, data_id)
    req(type %in% DataTypes)
    i <- which(sapply(cfg[[type]], function(x) x$id == data_id))
    req(length(i) == 1)
    if(!is.null(callback)) cfg[[type]][[i]] <- callback(cfg[[type]][[i]])
    write_data_yaml(cfg, type)
    config(cfg)
}

# delete a data yaml item
show_delete_alert <- function(type, data_id_name){
    cfg <- config()
    data_id <- input[[data_id_name]]
    req(cfg, data_id)
    req(type %in% DataTypes)
    shinyalert(
        title = "Delete Item?",
        text = paste("Are you sure you want to delete", data_id, "? This action cannot be undone."),
        type = "warning",
        showCancelButton = TRUE,
        confirmButtonCol = "#4CA63C",
        callbackR = function(confirmed){
            req(confirmed)
            i <- which(sapply(cfg[[type]], function(x) x$id == data_id))
            req(length(i) == 1)
            cfg[[type]] <- cfg[[type]][-i]
            write_data_yaml(cfg, type)
            config(cfg)
            shinyjs::runjs(paste0("Shiny.onInputChange('", data_id_name, "', 'CLEAR_ITEM')"))
        }
    )
}
