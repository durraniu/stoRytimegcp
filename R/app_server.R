#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function(input, output, session) {

  # telemetry$start_session(
  #   track_values = TRUE
  # )

  # Your application server logic
  story <- reactiveVal()
  all_imgs <- reactiveVal()



  output$html_story <- renderUI({

    file_path <- "www/example.html"

    # Check if file exists before rendering the iframe
    if (!file.exists(app_sys(paste0("app/", file_path)))) {
      return(tags$p("Waiting for the story..."))
    }

    tags$iframe(src= file_path,
                width="100%",
                height=600)
  })






  observeEvent(input$create_story, {
    req(input$story_prompt, input$num_of_sentences)

    withProgress(message = "Creating story and images ...", value = 0, {

      if (input$story_prompt != ""){

        # Show progress increment
        incProgress(0.3, detail = "Generating story...")

        # Get story from Workers AI model
        new_story <- get_story(
          prompt = input$story_prompt,
          num_of_sentences = input$num_of_sentences
        )

        # Process the story
        if (is.null(new_story)){
          new_story <- NULL
        } else {
            check_profanity <- sapply(new_story, test_profanity)
            if (all(check_profanity == FALSE)){
              new_story <- new_story
            } else {
              new_story <- NULL
            }
        }

        story(new_story)

        # Instructions for drawing each scene
        image_prompt <- paste0(
          "The background information for this scene is: ",
          input$story_prompt,
          ".
          ",
          input$drawing_instructions
        )

        # Increment progress for image generation
        incProgress(0.5, detail = "Generating images...")

        # Get images from Workers AI model
        if (is.null(story())){
          all_imgs(NULL)
        } else {
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
      }
      incProgress(1, detail = "Story and images created!")
    })

  }, ignoreInit = TRUE)








  observeEvent(input$create_story | input$update_theme, {

    previously_generated_file <- app_sys(paste0("app/", "www/generated_example.html"))

    if (file.exists(previously_generated_file)) {
      file.remove(previously_generated_file)
    }

    withProgress(message = "Building the slide deck ...", value = 0, {

    if (is.null(story()) | is.null(all_imgs())){
      # shinyalert::shinyalert("Oops!", "Something went wrong! Make sure you are not leaving the first sentence of the story blank and the # of sentences are more than 2. Try again!", type = "error")
      showNotification("Something went wrong! Make sure you are not leaving the first sentence of the story blank and the # of sentences are more than 2. Try again!", type = "error")
    } else if (!(length(story()) == length(all_imgs()))){
      # shinyalert::shinyalert("Oops!", "Something went wrong. Try again!", type = "error")
      showNotification("Oops! Something went wrong. Try again!", type = "error")
    } else if (length(story()) < 3){
      # shinyalert::shinyalert("Hold on!", "Please specify > 2 sentences.", type = "info")
      showNotification("Hold on! Either you specified or the API produced less than 3 sentences. Either specify > 2 sentences or try again.", type = "warning")
    } else {
      # Create a temp directory
      temp_dir <- tempdir()

      # Copy example.qmd from www folder to temp directory
      file.copy(app_sys("app/www/example.qmd"), file.path(temp_dir, "example.qmd"), overwrite = TRUE)

      # Path to the copied qmd file in the temp directory
      temp_qmd <- file.path(temp_dir, "example.qmd")
      temp_html <- file.path(temp_dir, "example.html")

      quarto::quarto_render(input = temp_qmd,
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

      incProgress(0.8, detail = "Slide deck generated!")


      # Define a target path in the www directory to copy the HTML
      www_dir <- app_sys("app/www")
      target_html <- file.path(www_dir, "generated_example.html")

      # Move the generated HTML to the www folder so it can be served by Shiny
      file.copy(temp_html, target_html, overwrite = TRUE)


      # Dynamically serve the updated HTML file from the temp folder
      output$html_story <- renderUI({
        # req(story(), all_imgs())
        # Check if the file exists before serving
        if (file.exists(target_html)) {
          tags$iframe(
            src = "www/generated_example.html",
            width = "100%",
            height = 600
          )
        } else {
          tags$p("Waiting for the story...")
        }
      })

      incProgress(1, detail = "Read your story!")
    }
})
  }, ignoreInit = TRUE)




  output$download_html <- downloadHandler(
    filename = function() {
      "generated_story.html"
    },
    content = function(file) {
      target_html <- app_sys("app/www/generated_example.html")

      # Ensure the file exists before allowing the download
      if (file.exists(target_html)) {
        # Copy the generated HTML file to the specified download location
        file.copy(target_html, file)
      } else {
        showNotification("No story available for download yet.", type = "error")
      }
    }
  )
}
