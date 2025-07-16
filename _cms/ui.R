#----------------------------------------------------------------------
# landing page
#----------------------------------------------------------------------
landingPageUI <- function(...){
    fluidRow(
        style = "margin: 10px;",
        tags$h3("Wilson Lab Website Content Management System (CMS)"),
        tags$p("Use the tabs at the left to navigate the CMS."),
        tags$p("Follow the instructions on each page to add, edit, or delete content.")
    )
}
#----------------------------------------------------------------------
# people management UI
#----------------------------------------------------------------------
dataTypePageUI <- function(singular, plural, ui){
    tagList(
        fluidRow(
            column(
                width = 12,
                tags$ul(
                    tags$li(paste("Drag and drop to change the order in which", plural, "are displayed.")),
                    tags$li(paste("Click on a", singular, "link to edit the displayed information.")), 
                    tags$li(paste("Use the buttons to add a new", singular, ", save your edits, or delete a", singular, "."))
                )
            )
        ),
        fluidRow(
            box(
                width = 12,
                title = plural,
                status = 'primary',
                solidHeader = TRUE,
                fluidRow(
                    style = "margin: 10px;",
                    column(
                        width = 4,
                        offset = 4,
                        bsButton(paste0("add_new_", tolower(singular)), paste("Add New", singular), style = "success", width = "100%")
                    )
                ),
                ui
            )
        ),
        fluidRow(
            box(
                width = 12,
                title = paste("Edit", singular),
                status = 'primary',
                solidHeader = TRUE,
                uiOutput(paste0("edit_", tolower(singular), "_ui"))
            )
        )
    )
}
eventsUI    <- function(...) dataTypePageUI("Event",    "Events",    uiOutput("events_rank_list_ui"))
fundingUI   <- function(...) dataTypePageUI("Funding",  "Funding",   uiOutput("funding_rank_list_ui"))
peopleUI    <- function(...) dataTypePageUI("Person",   "People",    uiOutput("people_rank_lists_ui"))
resourcesUI <- function(...) dataTypePageUI("Resource", "Resources", uiOutput("resources_rank_list_ui"))
#----------------------------------------------------------------------
# badge generation and item linking
#----------------------------------------------------------------------
badgesUI <- function(...){
    source('itemSelector.R', local = TRUE)
    source('itemReporter.R', local = TRUE)
    tagList(
        tags$ul(
            tags$li("Select two items and click ADD or REMOVE to establish a badge link between them."), # nolint
            tags$li("Copy a badge into a news post's markdown file as needed.")
        ),     
        fluidRow(
            itemReporterUI('item1', 1),
            box(
                width = 2,
                title = "-LINK-",
                status = 'primary',
                solidHeader = TRUE,
                uiOutput('linkAction')
            ),
            itemReporterUI('item2', 2)
        ),
        fluidRow(
            itemSelectorUI('item1', 1),
            itemSelectorUI('item2', 2)
        )
    )
}
#----------------------------------------------------------------------
# images viewing and link generation
#----------------------------------------------------------------------
imagesUI <- function(...){
    fluidRow(
        tags$ul(
            tags$li("To add an image, drag and drop it into Visual Studio Code into the proper folder under 'assets/images'."), # nolint
            tags$li("You may need to reload this browser."),
            tags$li("Copy the file path into 'card_image' or other image tag.")
        ),
        column(
            width = 7,
            box(
                width = 12,
                title = "File Selector",
                status = 'primary',
                solidHeader = TRUE,
                collapsible = TRUE,
                # custom search box
                shinyTree(
                    "fileTree",
                    checkbox = FALSE,
                    search = FALSE,
                    searchtime = 250,
                    dragAndDrop = FALSE,
                    types = NULL,
                    theme = "default",
                    themeIcons = FALSE,
                    themeDots = TRUE,
                    sort = FALSE,
                    unique = FALSE,
                    wholerow = TRUE,
                    stripes = FALSE,
                    multiple = FALSE,
                    animation = 200,
                    contextmenu = FALSE
                )
            ),
            box(
                width = 12,
                title = "Adjusted Image",
                status = 'primary',
                solidHeader = TRUE,
                textInput('adjustedFileName', 'Output File Path (!! do NOT include assets/images or .jpg !!)', ''),
                textOutput('adjustedImageSize'),
                actionButton('saveAdjustedImage', 'Save Image'),
                imageOutput('adjustedImage')
            )
        ),
        box(
            width = 5,
            title = "Selected Image",
            status = 'primary',
            solidHeader = TRUE,
            textInput('imagePathCopy', '', ''),
            textOutput('imageSize'),
            selectInput('imageType', 'Image Type', choices = c(
                'person_150_150',
                'banner_800',
                'banner_1200'
            )),
            imageOutput(
                'selectedImage', 
                height = '800px',
                brush = brushOpts(
                    id = 'imageBrush', 
                    fill = "#9cf", 
                    stroke = "#036",
                    opacity = 0.25, 
                    delay = 300, 
                    clip = FALSE,
                    resetOnNew = TRUE
                )
            )
        )
    )
}
#----------------------------------------------------------------------
# pubmed import UI
#----------------------------------------------------------------------
pubmedUI <- function(...){
    tagList(
        tags$ul(
            tags$li("go to ", "PubMed"), #a("PubMed", href = "https://pubmed.ncbi.nlm.nih.gov/")),
            tags$li("execute a search"),
            tags$li("set Display Options to 'PubMed'"),
            tags$li("copy entire contents to clipboad (e.g., Ctrl-A, Ctrl-C)"),
            tags$li("paste into the box below (e.g., Ctrl-V)")
        ),
        textAreaInput('pubmedImport', 'Paste PubMed formatted citations list here', rows = 5, width = '100%'),
        uiOutput('confirmPubmedImport')
    )
}
#----------------------------------------------------------------------
# set up the CMS page layout
#----------------------------------------------------------------------
htmlHeadElements <- function(){
        tags$head(
        tags$style(HTML("
            .action-link {
                color: #005bbb;
            }
            .action-link:hover {
                color: #a02943ff; /* Set your desired hover color here */
            }
        "))
        # tags$link(rel = "icon", type = "image/png", href = "logo/favicon-16x16.png"), # favicon
        # tags$link(href = "framework.css", rel = "stylesheet", type = "text/css"), # framework js and css
        # tags$script(src = "framework.js", type = "text/javascript", charset = "utf-8"),
        # tags$script(src = "ace/src-min-noconflict/ace.js", type = "text/javascript", charset = "utf-8")
    )
}
getTabMenuItem <- function(tabId, tabLabel){
    menuItem(
        tags$div(tabLabel,  class = "sidebar-action"), 
        tabName = tabId
    )  
}
getTabItem <- function(tabId, uiFn){
    tabItem(
        tabName = tabId, 
        uiFn(tabId)
    )
}
ui <- function(...){ 
    dashboardPage(
        dashboardHeader(
            title = "umich-labs",
            titleWidth = "175px"
        ),
        dashboardSidebar(
            sidebarMenu(id = "sidebarMenu",  
                getTabMenuItem('overview',  'Overview'),
                getTabMenuItem('events',    'Events'),
                getTabMenuItem('funding',   'Funding'),
                getTabMenuItem('people',    'People'),
                getTabMenuItem('resources', 'Resources'),
                getTabMenuItem('badges',    'Badges'),
                getTabMenuItem('images',    'Images'),
                getTabMenuItem('pubmed',    'Import Pubmed')
            ),
            htmlHeadElements(), # yes, place the <head> content here (even though i`t seems odd)
            width = "175px" # must be here, not in CSS
        ),
        dashboardBody(
            useShinyjs(), # enable shinyjs
            tabItems(
                getTabItem('overview',  landingPageUI),
                getTabItem('events',    eventsUI),
                getTabItem('funding',   fundingUI),
                getTabItem('people',    peopleUI),
                getTabItem('resources', resourcesUI),
                getTabItem('badges',    badgesUI),
                getTabItem('images',    imagesUI),
                getTabItem('pubmed',    pubmedUI)
            )
        )
    )
}
