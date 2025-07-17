# get events
event_items <- reactive({
    cfg <- config()
    req(cfg$events)
    I <- 1:length(cfg$events)
    labels <- lapply(I, function(i){
        id <- cfg$events[[i]]$id
        tags$div(
            actionLink(
                inputId = paste0('event_', id),
                label   = cfg$events[[i]]$title,
                class   = 'action-link',
                onclick = paste0("Shiny.onInputChange('edit_event_id', '", id, "')")
            )
        )
    })
    names(labels) <- sapply(I, function(i) cfg$events[[i]]$id)
    labels
})

# sortable lists that support moving people between statuses
output$events_rank_list_ui <- renderUI({
    rank_list(
        text = NULL, 
        labels = event_items(),
        input_id = "events_rank_list"
    )
})

# add event button
observeEvent(input$add_new_event, {
    add_item_alert(
        singular = "event",
        placeholder = "enter a short event name, can be a few words",
        callback = function(id, title){
            add_data_yaml_item("events", list(id = id, title = title))
        }
    )
})

# events editing UI
output$edit_event_ui <- renderUI({
    item_edit_ui("events", "edit_event", function(event){
        tagList(
            fluidRow(
                column(
                    width = 3,
                    textInput("edit_event_title", "Title", value = event$title)
                ),
                column(
                    width = 3,
                    textInput("edit_event_type", "Type", value = event$type)
                ),
                column(
                    width = 3,
                    dateInput("edit_event_date", "Date", value = event$date)
                ),
                column(
                    width = 3,
                    textInput("edit_event_location", "Location", value = event$location)
                )
            ),
            fluidRow(
                column(
                    width = 6,
                    textInput("edit_event_url", "URL", value = event$url)
                ),
                column(
                    width = 6,
                    textInput("edit_event_card_image", "Card Image", value = event$card_image)
                )
            ),
            fluidRow(
                column(
                    width = 12,
                    textInput("edit_event_description", "Description", value = event$description)
                )
            ),
            fluidRow(
                column(
                    width = 12,
                    markdownEditorUI("event", "events", event)
                )
            )
        )
    })
})

# event reordering
observeEvent(input$events_rank_list, {
    reorder_data_yaml("events", callback = function(cfg){
        events <- list()
        for(id in input$events_rank_list){
            event <- cfg$events[[which(sapply(cfg$events, function(x) x$id == id))]]
            events <- c(events, list(event))
        }
        events
    })
})

# save event edits
observeEvent(input$edit_event_save, {
    update_data_yaml("events", 'edit_event_id', callback = function(event){
        for(field in c(
            'title', 'type', 'date', 'location', 
            'url', 'card_image', 
            'description'
        )){
            value <- trimws(input[[paste0('edit_event_', field)]])
            if(value == '') value <- NULL
            event[[field]] <- value
        }
        write_item_markdown(
            "events", 
            event, 
            list(
                title      = event$title,
                subtitle   = event$date,
                card_image = event$card_image,
                card_title = NULL
            ), 
            input$edit_event_markdown
        )
        event
    })
})

# delete a event
observeEvent(input$edit_event_delete, {
    show_delete_alert("events", 'edit_event_id')
})
