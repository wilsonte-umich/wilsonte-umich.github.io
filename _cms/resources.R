# get resources
get_resource_items <- function(){
    cfg <- config()
    req(cfg$resources)
    I <- 1:length(cfg$resources)
    labels <- lapply(I, function(i){
        id <- cfg$resources[[i]]$id
        tags$div(
            actionLink(
                inputId = paste0('resource_', id),
                label   = cfg$resources[[i]]$title,
                class   = 'action-link',
                onclick = paste0("Shiny.onInputChange('edit_resource_id', '", id, "')")
            )
        )
    })
    names(labels) <- sapply(I, function(i) cfg$resources[[i]]$id)
    labels
}

# sortable lists that support moving people between statuses
output$resources_rank_list_ui <- renderUI({
    rank_list(
        text = NULL, 
        labels = get_resource_items(),
        input_id = "resources_rank_list"
    )
})

# add resource button
observeEvent(input$add_new_resource, {
    add_item_alert(
        singular = "Resource",
        placeholder = "enter a short resource name, can be a few words",
        callback = function(id, title){
            add_data_yaml_item("resources", list(id = id, title = title))
        }
    )
})

# resources editing UI
output$edit_resource_ui <- renderUI({
    item_edit_ui("resources", "edit_resource", function(resource){
        tagList(
            fluidRow(
                column(
                    width = 3,
                    textInput("edit_resource_title", "Title", value = resource$title)
                ),
                column(
                    width = 3,
                    textInput("edit_resource_type", "Type", value = resource$type)
                )
            ),
            fluidRow(
                column(
                    width = 12,
                    textInput("edit_resource_url", "URL", value = resource$url)
                )
            ),
            fluidRow(
                column(
                    width = 12,
                    textInput("edit_resource_description", "Description", value = resource$description)
                )
            )
        )
    })
})

# resource reordering
observeEvent(input$resources_rank_list, {
    reorder_data_yaml("resources", callback = function(cfg){
        resources <- list()
        for(id in input$resources_rank_list){
            resource <- cfg$resources[[which(sapply(cfg$resources, function(x) x$id == id))]]
            resources <- c(resources, list(resource))
        }
        resources
    })
})

# save resource edits
observeEvent(input$edit_resource_save, {
    update_data_yaml("resources", 'edit_resource_id', callback = function(resource){
        for(field in c('title', 'type', 'url', 'description')){
            value <- trimws(input[[paste0('edit_resource_', field)]])
            if(value == '') value <- NULL
            resource[[field]] <- value
        }
        resource
    })
})

# delete a resource
observeEvent(input$edit_resource_delete, {
    show_delete_alert("resources", 'edit_resource_id')
})
