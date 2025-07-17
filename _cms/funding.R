# get funding
funding_items <- reactive({
    cfg <- config()
    req(cfg$funding)
    I <- 1:length(cfg$funding)
    labels <- lapply(I, function(i){
        id <- cfg$funding[[i]]$id
        tags$div(
            actionLink(
                inputId = paste0('funding_', id),
                label   = cfg$funding[[i]]$title,
                class   = 'action-link',
                onclick = paste0("Shiny.onInputChange('edit_funding_id', '", id, "')")
            )
        )
    })
    names(labels) <- sapply(I, function(i) cfg$funding[[i]]$id)
    labels
})

# sortable lists that support moving people between statuses
output$funding_rank_list_ui <- renderUI({
    rank_list(
        text = NULL, 
        labels = funding_items(),
        input_id = "funding_rank_list"
    )
})

# add funding button
observeEvent(input$add_new_funding, {
    add_item_alert(
        singular = "funding",
        placeholder = "enter a grant number, like ES034143",
        callback = function(id, title){
            add_data_yaml_item("funding", list(id = id, title = title))
        }
    )
})

# funding editing UI
output$edit_funding_ui <- renderUI({
    item_edit_ui("funding", "edit_funding", function(funding){
        tagList(
            fluidRow(
                column(
                    width = 3,
                    textInput("edit_funding_sponsor", "Sponsor", value = funding$sponsor)
                ),
                column(
                    width = 3,
                    textInput("edit_funding_sponsor_id", "Sponsor ID", value = funding$sponsor_id)
                ),
                column(
                    width = 3,
                    textInput("edit_funding_grant_type", "Grant Type", value = funding$grant_type)
                )
            ),
            fluidRow(
                column(
                    width = 3,
                    dateInput("edit_funding_start_date", "Start Date", value = funding$start_date)
                ),
                column(
                    width = 3,
                    dateInput("edit_funding_end_date", "End Date", value = funding$end_date)
                ),
                column(
                    width = 6,
                    textInput("edit_funding_card_image", "Card Image", value = funding$card_image)
                )
            ),
            fluidRow(
                column(
                    width = 12,
                    textInput("edit_funding_sponsor_link", "Sponsor Link", value = funding$sponsor_link)
                )
            ),
            fluidRow(
                column(
                    width = 12,
                    textInput("edit_funding_title", "Title", value = funding$title)
                )
            ),
            fluidRow(
                column(
                    width = 12,
                    textAreaInput("edit_funding_description", "Description", value = funding$description)
                )
            ),
            fluidRow(
                column(
                    width = 12,
                    markdownEditorUI("funding", "funding", funding)
                )
            )
        )
    })
})

# funding reordering
observeEvent(input$funding_rank_list, {
    reorder_data_yaml("funding", callback = function(cfg){
        fundings <- list()
        for(id in input$funding_rank_list){
            funding <- cfg$funding[[which(sapply(cfg$funding, function(x) x$id == id))]]
            fundings <- c(fundings, list(funding))
        }
        fundings
    })
})

# save funding edits
observeEvent(input$edit_funding_save, {
    update_data_yaml("funding", 'edit_funding_id', callback = function(funding){
        for(field in c(
            'sponsor', 'sponsor_id', 'grant_type', 
            'start_date', 'end_date', 'card_image', 
            'sponsor_link', 
            'title', 
            'description'
        )){
            value <- trimws(input[[paste0('edit_funding_', field)]])
            if(value == '') value <- NULL
            funding[[field]] <- value
        }
        write_item_markdown(
            "funding", 
            funding, 
            list(
                title      = funding$title,
                subtitle   = paste(funding$start_date, "to", funding$end_date),
                card_image = funding$card_image,
                card_title = NULL
            ), 
            input$edit_funding_markdown
        )
        funding
    })
})

# delete a funding
observeEvent(input$edit_funding_delete, {
    show_delete_alert("funding", 'edit_funding_id')
})
