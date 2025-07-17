# functions to support ContentTypes stored in markdown files
# as well as extend content pages for DataTypes

# parse content file paths and contents
data_markdown_file <- function(type, item, archive = FALSE){
    typeDir <- paste0('_', type)
    dir <- file.path(rootDir, 'content',  typeDir)
    if(archive) dir <- file.path(dir, '_archive')
    file.path(dir, paste0(item$id, '.md'))
}

# read a content markdown file
read_item_markdown <- function(type, item, archive = FALSE){
    file <- data_markdown_file(type, item, archive)
    emptyItem <- list(frontmatter = list(), content = NULL)
    if(file.exists(file)){
        x <- slurpFile(file)
        x <- gsub('\r', '', x)
        x <- strsplit(x, "---\n")[[1]] # element 1 is empty, element 2 is the YAML header, element 3 is the content
        list(
            frontmatter = if(length(x) >= 2) read_yaml(text = paste0("---\n", x[2])) else list(),
            content     = if(length(x) >  2) x[3] else NULL
        )
    } else emptyItem
}

# write a content markdown file
write_item_markdown <- function(type, item, frontmatter, content){
    isDataType <- type %in% DataTypes
    content <- trimws(content)
    file <- data_markdown_file(type, item)
    if(!isTruthy(content) || nchar(content) == 0) {
        if(isDataType) {
            unlink(file, force = TRUE)
        } else {
            shinyalert(
                title = "Empty Content",
                text = paste("The markdown content for", type, "items cannot be empty."),
                type = "error",
                showCancelButton = FALSE,
                confirmButtonCol = "#4CA63C"
            )
        }
    } else {
        markdown <- paste0(
            "---\n",
            as.yaml(frontmatter, indent = 2),
            "---\n\n",
            content,
            if(endsWith(content, '\n')) '' else '\n'
        )
        writeLines(markdown, file)
    }
}
# create an Ace editor UI for editing Markdown content in the item edit UI
markdownEditorUI <- function(singular, plural, item) {
    placeholder <- "Edit the content of the item page in Markdown format.\n\n"
    if(plural %in% DataTypes) {
        placeholder <- paste(placeholder, "This extra content is optional for", singular, "items, so you may leave this blank.")
    }
    tags$div(
        tags$p(tags$strong(paste(singular, "Markdown Editor"))),
        aceEditor(
            outputId    = paste0("edit_", singular, "_markdown"),
            mode        = "markdown",
            theme       = "chrome",
            height      = "500px",
            value       = read_item_markdown(plural, item)$content,
            placeholder = placeholder,
            wordWrap    = TRUE,
            fontSize    = 14
        )
    )
}

# rewrite all content files whose frontmatter order or active state has changed
reorder_content_files <- function(type, frontmatter_fields, callback){
    cfg <- config()
    req(cfg)
    req(type %in% ContentTypes)
    ids_in <- names(cfg[[type]])
    req(ids_in)
    items <- callback(cfg)
    if(!identical(ids_in, sapply(items, function(x) x$id))){
        new <- list()
        for(item in items){
            id <- item$id
            if(cfg[[type]][[id]]$active != item$active || 
               cfg[[type]][[id]]$order  != item$order){
                frontmatter <- setNames(lapply(frontmatter_fields, function(field) item[[field]]), frontmatter_fields)
                write_item_markdown(type, item, frontmatter, item$content)
            }
            new[[id]] <- item
        }
        cfg[[type]] <- new
        config(cfg)
    }
}

# update a Content item
update_content_markdown <- function(type, data_id_name, frontmatter_fields, callback = NULL){
    cfg <- config()
    data_id <- input[[data_id_name]]
    req(cfg, data_id)
    req(type %in% ContentTypes)
    i <- which(names(cfg[[type]]) == data_id)
    req(length(i) == 1)
    if(!is.null(callback)) cfg[[type]][[data_id]] <- callback(cfg[[type]][[data_id]])
    item <- cfg[[type]][[data_id]]
    frontmatter <- setNames(lapply(frontmatter_fields, function(field) item[[field]]), frontmatter_fields)
    write_item_markdown(type, item, frontmatter, item$content)
    config(cfg)
    item
}

# move a Content item to the archive
move_content_to_archive <- function(type, item){
    file         <- data_markdown_file(type, item)
    archive_file <- data_markdown_file(type, item, archive = TRUE)
    unlink(archive_file, force = TRUE) # remove any existing archive file
    file.rename(file, archive_file)
    cfg <- config()
    cfg[[type]][[item$id]] <- NULL # remove from active list
    config(cfg)
}
