project_frontmatter_fields <- c(
    "title", "subtitle", "description", "card_image", "order", "active", "card_title", "categories"
)

#get projects by active state
get_projects_items <- function(active){
    cfg <- config()
    I <- which(sapply(cfg$projects, function(x) x$active == active))
    req(I)
    labels <- lapply(I, function(i){
        id <- cfg$projects[[i]]$id
        tags$div(
            actionLink(
                inputId = paste0('project_', id),
                label   = cfg$projects[[i]]$title,
                class   = 'action-link',
                onclick = paste0("Shiny.onInputChange('edit_project_id', '", id, "')")
            )
        )
    })
    names(labels) <- sapply(I, function(i) cfg$projects[[i]]$id)
    labels
}
projects_active   <- reactive({ get_projects_items(active = TRUE) })
projects_inactive <- reactive({ get_projects_items(active = FALSE) })

# sortable lists that support moving projects between active states
output$projects_rank_lists_ui <- renderUI({
    bucket_list(
        header = NULL,
        group_name = "projects_rank_lists",
        orientation = "horizontal",
        add_rank_list(
            text = HTML("<strong>Active Projects</strong>"),
            labels = projects_active(),
            input_id = "projects_rank_list_active"
        ),
        add_rank_list(
            text = HTML("<strong>Inactive Projects</strong>"),
            labels = projects_inactive(),
            input_id = "projects_rank_list_inactive"
        )
    )
})

# add project button
observeEvent(input$add_new_project, {
    add_item_alert(
        singular = "Project",
        placeholder = "enter project title (can be a few words)",
        callback = function(id, title){
            cfg <- config()
            maxActiveOrder <- max(sapply(cfg$projects, function(x) if(x$active) x$order else NA), na.rm = TRUE)
            content <- "REPLACE ME"
            cfg$projects[[id]] <- list(
                id          = id,
                title       = title,
                subtitle    = NULL,
                description = NULL,
                card_image  = NULL,
                order       = maxActiveOrder + 10L,
                active      = TRUE,
                card_title  = NULL,
                categories  = NULL,
                content     = content
            )
            write_item_markdown("projects", cfg$projects[[id]], cfg$projects[[id]][project_frontmatter_fields], content)
            config(cfg)
        }
    )
})

# project  editing UI
output$edit_project_ui <- renderUI({
    item_edit_ui("projects", "edit_project", function(project){
        tagList(
            fluidRow(
                column(
                    width = 3,
                    textInput("edit_project_title", "Title", value = project$title)
                ),
                column(
                    width = 3,
                    textInput("edit_project_subtitle", "Subtitle", value = project$subtitle)
                ),
                column(
                    width = 6,
                    textInput("edit_project_categories", "Categories", value = paste(project$categories, collapse = ","))
                )
            ),
            fluidRow(
                column(
                    width = 6,
                    textInput("edit_project_card_image", "Card Image", value = project$card_image)
                ),
                column(
                    width = 6,
                    textInput("edit_project_card_title", "Card Title", value = project$card_title)
                )
            ),
            fluidRow(
                column(
                    width = 12,
                    textInput("edit_project_description", "Description", value = project$description)
                )
            ),
            fluidRow(
                column(
                    width = 12,
                    markdownEditorUI("project", "projects", project)
                )
            )
        )
    })
})

# project reordering
observeEvent(input$projects_rank_lists, {
    reorder_content_files("projects", project_frontmatter_fields, callback = function(cfg){
        projects <- list()
        i <- 1L
        for(state in c("active", "inactive")){
            M <- if(state == "active") 1L else 100L
            for(id in input$projects_rank_lists[[paste0('projects_rank_list_', state)]]){
                project <- cfg$projects[[which(sapply(cfg$projects, function(x) x$id == id))]]
                project$active <- state == "active"
                project$order <- i * 10L * M
                projects <- c(projects, list(project))
                i <- i + 1L
            }
        }
        projects[order(sapply(projects, function(x) x$order))]
    })
})

# save project edits
observeEvent(input$edit_project_save, {
    update_content_markdown("projects", 'edit_project_id', project_frontmatter_fields, callback = function(project){
        for(field in c(
            'title', 'subtitle', 'categories', 
            'card_image', 'card_title', 
            'description'
        )){
            value <- trimws(input[[paste0('edit_project_', field)]])
            if(value == '') value <- NULL
            project[[field]] <- if(field == "categories") trimws(strsplit(value, ",")[[1]]) else value
        }
        project$content <- trimws(input$edit_project_markdown)
        project
    })
})

# delete a project
observeEvent(input$edit_project_delete, {
    show_delete_alert("projects", 'edit_project_id')
})
