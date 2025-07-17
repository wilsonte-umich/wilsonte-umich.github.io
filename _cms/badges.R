# handle badge generation and item linking

# set up the UI and server to match two items from different collections, i.e., of different types
source('itemSelector.R', local = TRUE)
source('itemReporter.R', local = TRUE)
item1 <- itemSelectorServer('item1', 1)
item2 <- itemSelectorServer('item2', 2)
itemReporterServer('item1', 1, item1)
itemReporterServer('item2', 2, item2)

# dynamically render either an add or remove link button, or no link at all for incompatible items
output$linkAction <- renderUI({
    target1 <- item1$item() # not a full item list
    target2 <- item2$item()
    req(target1, target2, target1$type != target2$type) # we never link items of the same type
    if(target1$badge %in% target2$badges || target2$badge %in% target1$badges) {
        actionButton('removeLinkButton', "REMOVE", width = "100%", style = button)
    } else {
        actionButton('addLinkButton',    "ADD",    width = "100%", style = button)
    }
})
observeEvent(input$removeLinkButton, { changeItemBadges(TRUE) })
observeEvent(input$addLinkButton,    { changeItemBadges(FALSE) })

# construct and dispatch the badge update action to Data or Content types
changeItemBadge <- function(cfg, type, target, changingBadge, remove){ # target may not be a full item list, but has badges and id
    if(is.null(target$badges)) target$badges <- character()
    if(remove) badges <- target$badges[target$badges != changingBadge]
            else badges <- unique(c(target$badges, changingBadge))
    if(length(badges) == 0) badges <- NULL
    i <- which(sapply(cfg[[type]], function(x) x$id == target$id))
    cfg[[type]][[i]]$badges <- sortItemBadges(badges) 
    if(type %in% DataTypes){
        write_data_yaml(cfg, type)
    } else {
        # must be newsfeed, projects are not tagged with badges
        item <- cfg[[type]][[i]]
        frontmatter <- setNames(lapply(newsfeed_frontmatter_fields, function(field) item[[field]]), newsfeed_frontmatter_fields)
        write_item_markdown(type, item, frontmatter, item$content)
    }
    cfg
}
changeItemBadges <- function(remove){
    cfg <- config()
    type1   <- item1$collection()$name
    type2   <- item2$collection()$name
    target1 <- item1$item() # not a full item list
    target2 <- item2$item()
    # projects are not tagged, but items can tag projects
    # newsfeed posts can tag items, but those items do not tag those newsfeed posts
    if(target1$type != 'project' && target2$type != 'post') cfg <- changeItemBadge(cfg, type1, target1, target2$badge, remove)
    if(target2$type != 'project' && target1$type != 'post') cfg <- changeItemBadge(cfg, type2, target2, target1$badge, remove)
    config(cfg)
}
