#----------------------------------------------------------------------
# landing page
#----------------------------------------------------------------------
landingPageUI <- function(...){
    fluidRow(
        style = "margin-left: 10px;",
        tags$h2("Wilson Lab Website - Content Management System (CMS)"),
        tags$p("Use the tabs at the left to navigate the CMS. Follow the instructions on each page to add, edit, or delete content, i.e, items of various types."),
        tags$p("Compare the website and existing items and files as a further guide to understanding how content gets displayed."),

        tags$h3("Badges that link items"),
        tags$p("Essentially all items have associated 'badges' that link them to other items."),
        tags$p("You should nearly always create badges using the 'Badges' tab, but can also manually edit YAML and markdown files to have entries like 'project=item_id'."),

        tags$h3("Standard markdown elements"),
        tags$p("Projects and the Newsfeed require item markdown files.",
               "Other data types can be optionally extended with item markdown files."),
        tags$p("Any standard markdown elements can be used in item markdown files that will be nicely formatted on the website - here are the most common."),
        tags$ul(
            tags$li("Headings: use #, ##, ### to create headings at different levels."),
            tags$li("Bullet points: use - to create bullet points."),
            tags$li("Links: use [Link Text](https://link.target.com) to create a link to an external web page, or simply wrap the URL as <https://link.target.com>.")
        ),
        tags$pre("
### Section Heading

Paragraph text, with a link to [Link Text](https://link.target.com), 
or <https://link.target.com>.

Additional information:
- Bullet point 1
- Bullet point 2"),

        tags$h3("Custom elements to include in item markdown files"),
        tags$p("The following shows how to add custom formatted elements within your markdown files using Jekyll 'include' syntax."),
        tags$h4("Embedded Figure", style = "margin-top: 20px;"),
        tags$p("Create an embedded figure (use width==12 for full width). The image file must be in the assets/images folder in any subfolder."),
        tags$pre("
{% include figure.html
    image=\"assets/images/xxx.jpg\"
    title=\"Figure Title\"
    caption=\"Figure caption text.\"
    width=8
%}"),
        tags$h4("PubMed Citation Link", style = "margin-top: 20px;"),
        tags$p("Create a PubMed citation link ('search' can be any PubMed query string; one or more PMIDs is typical)."),
        tags$pre("
{% include citation.html search=\"32665662 30598553\" %}"),

        tags$p("", style = "margin-bottom: 50px;"),
    )
}
#----------------------------------------------------------------------
# site editing UI, for more static page markdown and YAML configuration files
#----------------------------------------------------------------------
siteEditorUI <- function(...){
    tagList(
        fluidRow(
            column(
                width = 12,
                tags$ul(
                    tags$li(paste("Use this interface to edit the more fixed elements of page layouts (rather than the more frequently updated content items).")),
                    tags$li(paste("Select a file from the dropdown menu to edit its header/up-front content as Markdown or YAML.")),
                    tags$li(paste("Be sure to click the Save button, changes are NOT automatically saved!")),
                )
            )
        ),
        fluidRow(
            box(
                width = 12,
                title = NULL,
                status = 'primary',
                solidHeader = FALSE,
                fluidRow(
                    style = "margin: 10px;",
                    column(
                        width = 4,
                        offset = 4,
                        selectInput(
                            'site_file', 
                            'Select Site File to Edit', 
                            choices = c("pending"),
                            selected = 'pending'
                        )
                    )
                )
            )
        ),
        fluidRow(
            box(
                width = 12,
                title = "File Editor",
                status = 'primary',
                solidHeader = TRUE,
                fluidRow(
                    style = "margin: 10px;",
                    column(
                        width = 4,
                        offset = 4,
                        bsButton('save_site_file', 'Save Site File', style = "success", width = "100%")
                    )
                ),
                fluidRow(
                    style = "margin: 10px;",
                    uiOutput("edit_site_file_ui")
                )
            )
        )
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
projectsUI  <- function(...) dataTypePageUI("Project",  "Projects",  uiOutput("projects_rank_lists_ui"))
newsfeedUI  <- function(...) dataTypePageUI("Newsfeed", "Newsfeed",  uiOutput("newsfeed_rank_list_ui"))
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
                getTabMenuItem('site',      'Site Layout'),
                getTabMenuItem('events',    'Events'),
                getTabMenuItem('funding',   'Funding'),
                getTabMenuItem('people',    'People'),
                getTabMenuItem('resources', 'Resources'),
                getTabMenuItem('projects',  'Projects'),
                getTabMenuItem('newsfeed',  'Newsfeed'),
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
                getTabItem('site',      siteEditorUI),
                getTabItem('events',    eventsUI),
                getTabItem('funding',   fundingUI),
                getTabItem('people',    peopleUI),
                getTabItem('resources', resourcesUI),
                getTabItem('projects',  projectsUI),
                getTabItem('newsfeed',  newsfeedUI),
                getTabItem('badges',    badgesUI),
                getTabItem('images',    imagesUI),
                getTabItem('pubmed',    pubmedUI)
            )
        )
    )
}
