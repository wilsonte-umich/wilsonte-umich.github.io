#get people by status
get_people_items <- function(status){
    cfg <- config()
    I <- which(sapply(cfg$people, function(x) x$status == status))
    req(I)
    labels <- lapply(I, function(i){
        id <- cfg$people[[i]]$id
        tags$div(
            actionLink(
                inputId = paste0('person_', id),
                label   = cfg$people[[i]]$name,
                class   = 'action-link',
                onclick = paste0("Shiny.onInputChange('edit_person_id', '", id, "')")
            )
        )
    })
    names(labels) <- sapply(I, function(i) cfg$people[[i]]$id)
    labels
}
people_active       <- reactive({ get_people_items('active')})
people_collaborator <- reactive({ get_people_items('collaborator')})
people_past         <- reactive({ get_people_items('past') })

# sortable lists that support moving people between statuses
output$people_rank_lists_ui <- renderUI({
    bucket_list(
        header = NULL,
        group_name = "people_rank_lists",
        orientation = "horizontal",
        add_rank_list(
            text = HTML("<strong>Active Lab Members</strong>"),
            labels = people_active(),
            input_id = "people_rank_list_active"
        ),
        add_rank_list(
            text = HTML("<strong>Collaborators</strong>"),
            labels = people_collaborator(),
            input_id = "people_rank_list_collaborator"
        ),
        add_rank_list(
            text = HTML("<strong>Past Lab Members</strong>"),
            labels = people_past(),
            input_id = "people_rank_list_past"
        )
    )
})

# add person button
observeEvent(input$add_new_person, {
    add_item_alert(
        singular = "Person",
        placeholder = "enter person name as: FirstName LastName",
        callback = function(id, name){
            add_data_yaml_item("people", list(id = id, name = name, status = "active"))
        }
    )
})

# people editing UI
output$edit_person_ui <- renderUI({
    item_edit_ui("people", "edit_person", function(person){
        tagList(
            fluidRow(
                column(
                    width = 3,
                    textInput("edit_person_name", "Name", value = person$name)
                ),
                column(
                    width = 3,
                    textInput("edit_person_role", "Role", value = person$role)
                ),
                column(
                    width = 3,
                    textInput("edit_person_program", "Program", value = person$program)
                ),
                column(
                    width = 3,
                    selectInput("edit_person_status", "Status", choices = c("active", "collaborator", "past"), selected = person$status)
                )
            ),
            fluidRow(
                column(
                    width = 3,
                    textInput("edit_person_email", "Email", value = person$email)
                ),
                column(
                    width = 3,
                    textInput("edit_person_orcid", "ORCID", value = person$orcid)
                ),
                column(
                    width = 3,
                    textInput("edit_person_github", "GitHub", value = person$github)
                ),
                column(
                    width = 3,
                    textInput("edit_person_twitter", "Twitter", value = person$twitter)
                )
            ),
            fluidRow(
                column(
                    width = 6,
                    textInput("edit_person_image", "Headshot Image", value = person$image)
                ),
                column(
                    width = 6,
                    textInput("edit_person_card_image", "Card Image", value = person$card_image)
                )
            ),
            fluidRow(
                column(
                    width = 12,
                    textInput("edit_person_description", "Description", value = person$description)
                )
            ),
            fluidRow(
                column(
                    width = 12,
                    markdownEditorUI("person", "people", person)
                )
            )
        )
    })
})

# person reordering
observeEvent(input$people_rank_lists, {
    reorder_data_yaml("people", callback = function(cfg){
        people <- list()
        for(status in c('active', 'collaborator', 'past')){
            for(id in input$people_rank_lists[[paste0('people_rank_list_', status)]]){
                person <- cfg$people[[which(sapply(cfg$people, function(x) x$id == id))]]
                person$status <- status
                people <- c(people, list(person))
            }
        }
        people
    })
})

# save person edits
observeEvent(input$edit_person_save, {
    update_data_yaml("people", 'edit_person_id', callback = function(person){
        for(field in c(
            'name', 'role', 'program', 'status', 
            'email', 'orcid', 'github', 'twitter', 
            'image', 'card_image', 
            'description'
        )){
            value <- trimws(input[[paste0('edit_person_', field)]])
            if(value == '') value <- NULL
            person[[field]] <- value
        }
        write_item_markdown(
            "people", 
            person, 
            list(
                title      = person$name,
                subtitle   = person$role,
                card_image = person$card_image,
                card_title = NULL
            ), 
            input$edit_person_markdown
        )
        person
    })
})

# delete a person
observeEvent(input$edit_person_delete, {
    show_delete_alert("people", 'edit_person_id')
})
