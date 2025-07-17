# site file selector
nullSiteFile <- '--select a file--'
siteConfigYml <- '_config.yml'
observe({
    basePath      <- file.path(rootDir, '_data/base')
    baseYamlFiles <- list.files(path = basePath, full.names = FALSE, pattern = '\\.yml$')
    pagesPath     <- file.path(rootDir, '/pages')
    pageMdFiles   <- list.files(path = pagesPath, full.names = FALSE, pattern = '\\.md$')
    files <- c(baseYamlFiles, pageMdFiles)
    files <- files[!startsWith(files, '_')]
    files <- c(nullSiteFile, siteConfigYml, files)
    updateSelectInput(session, 'site_file', choices = files, selected = nullSiteFile)
})

# interpret the selected site file
site_file <- reactive({
    site_file <- input$site_file
    req(site_file, site_file != nullSiteFile)
    dir <- if (site_file == siteConfigYml) file.path(rootDir) 
           else if(endsWith(site_file, '.yml')) file.path(rootDir, '_data/base') 
           else file.path(rootDir, 'pages')
    list(
        file = file.path(dir, site_file),
        mode = if(endsWith(site_file, '.yml')) 'yaml' else 'markdown'
    )
})

# Ace file editor
output$edit_site_file_ui <- renderUI({
    site_file <- site_file()
    contents <- slurpFile(site_file$file)
    contents <- gsub('\r', '', contents) # remove any Windows line endings
    aceEditor(
        outputId    = 'edit_site_file',
        mode        = site_file$mode,
        theme       = "chrome",
        height      = "500px",
        value       = contents,
        wordWrap    = TRUE,
        fontSize    = 14
    )
})

# save the edited site file
observeEvent(input$save_site_file, {
    site_file <- site_file()
    req(site_file, site_file != nullSiteFile)
    contents <- gsub('\r', '', input$edit_site_file) # remove any Windows line endings
    writeLines(contents, site_file$file)
})
