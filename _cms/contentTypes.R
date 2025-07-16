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
            placeholder = placeholder
        )
    )
}

