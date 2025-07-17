newsfeed_frontmatter_fields <- c(
    "date", "title", "subtitle", "description", "event_type", "banner_image_source","badges"
)

# get newsfeed items
newsfeed_items <- reactive({
    cfg <- config()
    I <- 1:length(cfg$newsfeed)
    labels <- lapply(I, function(i){
        id <- cfg$newsfeed[[i]]$id
        tags$div(
            actionLink(
                inputId = paste0('newsfeed_', id),
                label   = paste(cfg$newsfeed[[i]]$date, cfg$newsfeed[[i]]$title, sep = " - "),
                class   = 'action-link',
                onclick = paste0("Shiny.onInputChange('edit_newsfeed_id', '", id, "')")
            )
        )
    })
    names(labels) <- sapply(I, function(i) cfg$newsfeed[[i]]$id)
    labels
})

# sortable lists that support moving newsfeeds between active states
output$newsfeed_rank_list_ui <- renderUI({
    rank_list(
        text = NULL,
        labels = newsfeed_items(),
        input_id = "newsfeeds_rank_list",
        options = sortable_options(
            disabled = TRUE
        )
    )
})

# add newsfeed post button
observeEvent(input$add_new_newsfeed, {
    add_item_alert(
        singular = "Newsfeed Post",
        placeholder = "enter newsfeed post title (can be a few words)",
        callback = function(id, title){
            cfg <- config()
            date <- as.character(Sys.Date())
            content <- "REPLACE ME"
            id <- paste0(date, '-', gsub(' ', '-', tolower(title)))
            cfg$newsfeed[[id]] <- list(
                id          = id,
                date        = date,
                title       = title,
                subtitle    = NULL,
                description = NULL,
                event_type  = 'person',
                banner_image_source = 'project=MDI',
                badges      = NULL,
                content     = content
            )
            write_item_markdown("newsfeed", cfg$newsfeed[[id]], cfg$newsfeed[[id]][newsfeed_frontmatter_fields], content)
            cfg$newsfeed <- cfg$newsfeed[order(sapply(cfg$newsfeed, function(x) x$date), decreasing = TRUE)]
            config(cfg)
        }
    )
})

# newsfeed editing UI
output$edit_newsfeed_ui <- renderUI({
    item_edit_ui("newsfeed", "edit_newsfeed", function(newsfeed){
        tagList(
            fluidRow(
                column(
                    width = 3,
                    dateInput("edit_newsfeed_date", "Date", value = newsfeed$date)
                ),
                column(
                    width = 3,
                    textInput("edit_newsfeed_title", "Title", value = newsfeed$title)
                ),
                column(
                    width = 3,
                    textInput("edit_newsfeed_subtitle", "Subtitle", value = newsfeed$subtitle)
                ),
                column(
                    width = 3,
                    checkboxInput("edit_newsfeed_move_to_archive", "Move to Archive", value = FALSE)
                )
            ),
            fluidRow(
                column(
                    width = 3,
                    selectInput("edit_newsfeed_event_type", "Event Type", selected = newsfeed$event_type,
                                choices = c("event", "funding", "person", "project", "resource", "publication"))
                ),
                column(
                    width = 3,
                    textInput("edit_newsfeed_banner_image_source", "Banner Image Source", value = newsfeed$banner_image_source, 
                              placeholder = "e.g., person=person_id")
                )
            ),
            fluidRow(
                column(
                    width = 12,
                    textInput("edit_newsfeed_description", "Description", value = newsfeed$description)
                )
            ),
            fluidRow(
                column(
                    width = 12,
                    markdownEditorUI("newsfeed", "newsfeed", newsfeed)
                )
            )
        )
    })
})

# save newsfeed edits
observeEvent(input$edit_newsfeed_save, {
    dateWasChanged <- FALSE
    moveToArchive <- input$edit_newsfeed_move_to_archive
    id_in <- input$edit_newsfeed_id
    post <- update_content_markdown("newsfeed", 'edit_newsfeed_id', newsfeed_frontmatter_fields, callback = function(post){
        date_in <- post$date
        for(field in c(
            'date', 'title', 'subtitle', 
            'event_type', 'banner_image_source',
            'description'
        )){
            value <- trimws(input[[paste0('edit_newsfeed_', field)]])
            if(value == '') value <- NULL
            post[[field]] <- value
        }
        post$content <- trimws(input$edit_newsfeed_markdown)
        date_out <- post$date
        if(date_in != date_out){
            unlink(data_markdown_file("newsfeed", post), force = TRUE)
            post$id <- paste0(date_out, '-', gsub(' ', '-', tolower(post$title)))
            dateWasChanged <<- TRUE
        }
        archiveId <<- post$id
        post
    })
    if(moveToArchive){
        move_content_to_archive("newsfeed", post)
    } else if(dateWasChanged){
        cfg <- config()
        cfg$newsfeed[[post$id]] <- post
        cfg$newsfeed[[id_in]] <- NULL
        cfg$newsfeed <- cfg$newsfeed[order(sapply(cfg$newsfeed, function(x) x$date), decreasing = TRUE)]
        config(cfg)
    }
})

# delete a newsfeed post
observeEvent(input$edit_newsfeed_delete, {
    show_delete_alert("newsfeed", 'edit_newsfeed_id')
})
