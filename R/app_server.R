#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function(input, output, session) {
  # Your application server logic
  story <- reactiveVal()
  all_imgs <- reactiveVal()


  observeEvent(input$create_story, {

    if (input$story_prompt != ""){

      # Get story from Workers AI model
      new_story <- get_story(
        prompt = input$story_prompt,
        num_of_sentences = input$num_of_sentences
      )

      story(new_story)

      # Instructions for drawing each scene
      image_prompt <- paste0(
        "The background information for this scene is: ",
        input$story_prompt,
        ".
        ",
        input$drawing_instructions
      )

      # Get images from Workers AI model
      reqs <- lapply(
        story(),
        function(x){
          req_single_image(x, image_prompt)
        }
      )

      resps <- httr2::req_perform_parallel(reqs, on_error = "continue")

      # All images
      new_all_imgs <- lapply(resps, get_image)
      all_imgs(new_all_imgs)

    }

  }, ignoreInit = TRUE)



  observeEvent(input$create_story | input$update_theme, {

    if (!(length(story()) == length(all_imgs()))){
      shinyalert::shinyalert("Oops!", "Something went wrong. Try again!", type = "error")
    } else {
      quarto::quarto_render(input = app_sys("app/www/example.qmd"),
                            output_format = "all",
                            metadata = list(theme = input$story_theme,
                                            "title-slide-attributes" = list(
                                              "data-background-image" = paste0("data:image/png;base64,", base64enc::base64encode(utils::tail(all_imgs(), 1)[[1]])),
                                              "data-background-size" = "cover",
                                              "data-background-opacity" = 0.3
                                            )),
                            quarto_args = c("--metadata",
                                            paste0("title=", input$story_title)),
                            execute_params = list(
                              story_prompt = input$story_prompt,
                              story = story(),
                              imgs = lapply(all_imgs(), base64enc::base64encode)
                            ),
                            quiet = FALSE
      )
    }

  }, ignoreInit = TRUE)

  html_content <- reactiveFileReader(
    intervalMillis = 5000,  # Check for changes every 5 seconds
    session = session,
    filePath = app_sys("app/www/example.html"),
    readFunc = rvest::read_html
  )

  output$html_story <- renderUI({

    html_content()

    file_path <- "www/example.html"

    # Add a cache-busting query parameter with the current timestamp
    cache_buster <- Sys.time()

    # if (!file.exists(file_path)){
    #   return(tags$p("Waiting for the story..."))
    # }

    tags$iframe(src= paste0(file_path, "?t=", as.numeric(cache_buster)),
                width="100%",
                height=600)
  })
}
