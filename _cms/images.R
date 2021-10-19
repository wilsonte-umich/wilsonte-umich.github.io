#----------------------------------------------------------------------
# initialize file selector tree
#----------------------------------------------------------------------

# store file paths for validating leaf status (i.e. file, not directory)
treeFiles <- character()
relImagesDir <- file.path('assets', 'images')
imagesDir <- file.path(rootDir, relImagesDir)

# set behavior for cropping and resizing
cropAttributes <- list(
    person_150_150 = list(x = 150, y = 150),
    banner_800 = list(x = 800),
    banner_1200 = list(x = 1200)
)

# render the file tree
getImageFileTree <- function(){

    # collect and sort the files list
    treeFiles <<- list.files(imagesDir, recursive = TRUE)
    x <- strsplit(treeFiles, '/')
    lenX <- sapply(x, length)
    maxLen <- max(lenX)
    x <- cbind(lenX == 1, as.data.frame(t(sapply(seq_along(x), function(i) c(x[[i]], rep(NA, maxLen - lenX[i]))))))
    order <- do.call(order, x)
    x <- x[order, ][, 2:ncol(x)]
    lenX <- lenX[order]
    nRows <- nrow(x)
    req(nRows)
    rowIs <- 1:nRows

    # process the files list is a list of lists compatible with ShinyTree
    # note that it is the names (not the values) of the list that represent the tree content
    parseLevel <- function(rows, col){
        uniqNames <- unique(x[rows, col])
        list <- lapply(uniqNames, function(name){
            rows_ <- which(x[[col]] == name & rowIs %in% rows)
            if(length(rows_) == 1 && lenX[rows_] == col) '' # a terminal leaf (i.e. a file)
            else parseLevel(rows_, col + 1) # a node (i.e. a directory)
        })
        names(list) <- uniqNames
        list
    }

    # recurse through the file structure
    parseLevel(rowIs, 1) 
}
output$fileTree <- renderTree({
    getImageFileTree()
})

# respond to a file tree click, i.e., the current selected image
selectedImagePath <- reactive({
    req(input$fileTree)
    x <- get_selected(input$fileTree)
    req(length(x) == 1) # == 0 when not selected; never >0 since multi-select disabled
    x <- x[[1]]
    x <- paste(c(attr(x, 'ancestry'), x), collapse = "/") # reassemble the file path relative to tree root
    req(x %in% treeFiles)
    relPath <- file.path(relImagesDir, x)
    updateTextInput(session, 'imagePathCopy', value = relPath)
    updateAdjustedImage(0)
    file.path(rootDir, relPath)
})
getImageSize <- function(path){ # provide feedback about an image properties
    req(path)
    img <- image_read(path)
    info <- image_info(img)
    KB <- paste0(round(info$filesize / 1000), "KB")
    size <- paste(info$width, info$height, sep = " x ")
    paste(size, KB, sep = ", ")     
}
output$imageSize <- renderText({
    getImageSize(selectedImagePath())    
})
output$selectedImage <- renderImage({ # show the selected image, with brush selection for cropping
    req(selectedImagePath())    
    list(
        src = selectedImagePath(),
        width = '100%',
        style = "margin-top: 10px; border: 1px solid grey;"
    )
}, deleteFile = FALSE)

# handle image brush to crop and resize
tmpFile <- file.path(imagesDir, "TMP.jpg")
observeEvent(input$imageBrush, {
    req(selectedImagePath()) 
    box <- input$imageBrush$coords_img
    xmin <- round(box$xmin)
    xmax <- round(box$xmax)
    ymin <- round(box$ymin)
    ymax <- round(box$ymax)
    if(xmin <= 1) x <- 1
    if(ymin <= 1) x <- 1
    attr <- cropAttributes[[input$imageType]]
    if(is.null(attr$y)){ # control image width only
    } else { # enforce a specific aspect ratio
        targetAspectRatio <- attr$y / attr$x
        selectedWidth <- xmax - xmin
        selectedHeight <- ymax - ymin
        selectedAspectRatio <- selectedHeight / selectedWidth
        if(selectedAspectRatio >= targetAspectRatio){
            ymax <- round(ymin + selectedHeight * targetAspectRatio / selectedAspectRatio)
        } else {
            xmax <- round(xmin + selectedWidth * selectedAspectRatio / targetAspectRatio)
        }
    }
    crop <- paste0(xmax - xmin, 'x', ymax - ymin, '+', xmin, '+', ymin)
    scale <- as.character(attr$x)
    image_read(selectedImagePath()) %>% 
    image_crop(crop) %>% 
    image_scale(scale) %>% 
    image_background('white', flatten = TRUE) %>%
    image_write(path = tmpFile, format = "jpg")
    updateAdjustedImage( updateAdjustedImage() + 1 )
})
updateAdjustedImage <- reactiveVal(0)
output$adjustedImageSize <- renderText({
    req(updateAdjustedImage() > 0)
    getImageSize(tmpFile)    
})
output$adjustedImage <- renderImage({ # preview the cropped and scaled image prior to saving
    req(updateAdjustedImage() > 0)
    list(
        src = tmpFile,
        width = '100%',
        style = "margin-top: 10px; border: 1px solid grey;"
    )
}, deleteFile = FALSE)

# handle a file save click
adjustedFileName <- reactive({ # set the file path from the input
    req(input$adjustedFileName)
    filename <- paste0(input$adjustedFileName, '.jpg')
    list(
        relative = file.path(relImagesDir, filename),
        absolute = file.path(imagesDir,    filename)
    )
})
observeEvent(input$saveAdjustedImage, { # confirm the image save action
    req(adjustedFileName())
    file.copy(tmpFile, adjustedFileName()$absolute, overwrite = TRUE)
    updateTree(session, 'fileTree', getImageFileTree())
    # showModal(modalDialog(
    #     tags$p('Create/overwrite image file?'),
    #     tags$p(adjustedFileName()$relative),
    #     footer = tagList(
    #         modalButton("Cancel"),
    #         actionButton("doSaveAdjustedImaged", "OK")
    #     )
    # ))
})
# observeEvent(input$doSaveAdjustedImaged, { # commit the new image file
#     file.copy(tmpFile, adjustedFileName()$absolute, overwrite = TRUE)
#     updateTree(session, 'fileTree', getImageFileTree())
#     removeModal()
# })
