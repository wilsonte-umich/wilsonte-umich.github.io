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
    out <- cfg[[type]]
    names(out) <- NULL # ensures that data.yml files are lists of hashes; badge handling might have added names
    write_yaml(out, main_file)
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

# update a DataType item markdown content
update_data_markdown <- function(type, markdown){
    markdown <- trimws(markdown)
    req(nchar(markdown) > 0)


    cfg <- config()
    data_id <- input[[paste0("edit_", tolower(type), "_id")]]
    req(cfg, data_id)
    req(type %in% DataTypes)
    i <- which(sapply(cfg[[type]], function(x) x$id == data_id))
    req(length(i) == 1)
    cfg[[type]][[i]]$markdown <- markdown
    write_data_yaml(cfg, type)
    config(cfg)
}
