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

  # Create a temporary directory specific to this session
  session_temp_dir <- tempfile(pattern = paste0("quarto_output_", session$token, "_"))
  dir.create(session_temp_dir)

  # Clean up the temporary directory when the session ends
  onStop(function() {
    unlink(session_temp_dir, recursive = TRUE)
  })

  # Function to serve files from the temporary directory
  serve_temp_file <- function(filename) {
    file_path <- file.path(session_temp_dir, filename)
    if (!file.exists(file_path)) {
      return(NULL)
    }

    # Create a random identifier for cache busting
    cache_buster <- paste0("v=", as.numeric(Sys.time()))

    # Remove any existing resource path for this session
    if (paste0("temp_", session$token) %in% resourcePaths()) {
      removeResourcePath(paste0("temp_", session$token))
    }

    # Serve the file with proper mime type
    shiny::addResourcePath(
      prefix = paste0("temp_", session$token),
      directoryPath = session_temp_dir
    )

    # Return the URL with cache buster
    paste0("/temp_", session$token, "/", filename, "?", cache_buster)
  }

  # Single observer for both story creation and rendering
  observeEvent(input$create_story, {
    req(input$story_prompt, input$num_of_sentences)

    # Reset reactive values at the start
    story(NULL)
    all_imgs(NULL)

    print("story nullified")

    withProgress(message = "Creating story and images ...", value = 0, {
      if (input$story_prompt != "") {
        # Show progress increment
        incProgress(0.2, detail = "Generating story...")

        # Get story from Workers AI model
        new_story <- get_story(
          prompt = input$story_prompt,
          num_of_sentences = input$num_of_sentences
        )

        print(new_story)

        # Process the story
        if (is.null(new_story)) {
          story(NULL)
          return()
        } else {
          # check_profanity <- sapply(new_story, test_profanity)
          # print(check_profanity)
          # if (all(check_profanity == FALSE)) {
            print("Story made")
            story(new_story)
          # } else {
          #   story(NULL)
          #   return()
          # }
        }

        # Instructions for drawing each scene
        image_prompt <- paste0(
          "The background information for this scene is: ",
          input$story_prompt,
          ".\n",
          input$drawing_instructions
        )

        # Increment progress for image generation
        incProgress(0.4, detail = "Generating images...")

        # Get images from Workers AI model
        if (is.null(story())) {
          all_imgs(NULL)
          return()
        } else {
          reqs <- lapply(
            story(),
            function(x) {
              req_single_image(x, image_prompt)
            }
          )
          resps <- httr2::req_perform_parallel(reqs, on_error = "continue")

          # All images
          new_all_imgs <- lapply(resps, get_image)
          all_imgs(new_all_imgs)
        }

        # Verify we have valid content before proceeding
        req(story(), all_imgs())
        req(length(story()) == length(all_imgs()))

        # Increment progress for Quarto rendering
        incProgress(0.6, detail = "Generating slide deck...")

        # Copy the template QMD to temp directory
        template_qmd <- app_sys("app/www/example.qmd")
        file.copy(template_qmd, file.path(session_temp_dir, "example.qmd"), overwrite = TRUE)

        # Save current working directory
        original_wd <- getwd()

        # Change to temp directory for rendering
        setwd(session_temp_dir)


        # browser()

        print(story())
        print(length(all_imgs()))

        # Use tryCatch to ensure we always restore the working directory
        # tryCatch({
          # Render in the temporary directory
          quarto::quarto_render(
            input = "example.qmd",  # Just the filename since we're in the right directory
            output_format = "all",
            metadata = list(
              theme = input$story_theme,
              "title-slide-attributes" = list(
                "data-background-image" = paste0("data:image/png;base64,",
                                                 base64enc::base64encode(utils::tail(all_imgs(), 1)[[1]])),
                "data-background-size" = "cover",
                "data-background-opacity" = 0.3
              )
            ),
            quarto_args = c("--metadata", paste0("title=", input$story_title)),
            execute_params = list(
              story_prompt = input$story_prompt,
              story = story(),
              imgs = lapply(all_imgs(), base64enc::base64encode)
            ),
            quiet = TRUE
          )
        # },
        # finally = {
        #   # Restore original working directory
          setwd(original_wd)
        # })

        incProgress(1, detail = "Finalizing...")
      }
    })
  }, ignoreInit = TRUE)

  # Separate observer for theme updates
  observeEvent(input$update_theme, {
    req(story(), all_imgs())
    req(length(story()) == length(all_imgs()))

    withProgress(message = "Updating theme...", value = 0, {
      # Copy the template QMD to temp directory
      template_qmd <- app_sys("app/www/example.qmd")
      file.copy(template_qmd, file.path(session_temp_dir, "example.qmd"), overwrite = TRUE)

      # Save current working directory
      original_wd <- getwd()

      # Change to temp directory for rendering
      setwd(session_temp_dir)

      # browser()

      # Use tryCatch to ensure we always restore the working directory
      # tryCatch({
        quarto::quarto_render(
          input = "example.qmd",
          output_format = "all",
          metadata = list(
            theme = input$story_theme,
            "title-slide-attributes" = list(
              "data-background-image" = paste0("data:image/png;base64,",
                                               base64enc::base64encode(utils::tail(all_imgs(), 1)[[1]])),
              "data-background-size" = "cover",
              "data-background-opacity" = 0.3
            )
          ),
          quarto_args = c("--metadata", paste0("title=", input$story_title)),
          execute_params = list(
            story_prompt = input$story_prompt,
            story = story(),
            imgs = lapply(all_imgs(), base64enc::base64encode)
          ),
          quiet = TRUE
        )
      # },
      # finally = {
        setwd(original_wd)
      # })

      incProgress(1, detail = "Theme updated!")
    })
  }, ignoreInit = TRUE)

  # Update UI whenever the file changes
  observe({
    input$update_theme
    req(story(), all_imgs())

    output$html_story <- renderUI({
      # Check if the rendered file exists
      output_file <- file.path(session_temp_dir, "example.html")
      req(file.exists(output_file))

      # Get URL for the temp file with cache busting
      file_url <- serve_temp_file("example.html")

      tags$iframe(
        src = file_url,
        width = "100%",
        height = 600,
        # Add a unique key to force iframe refresh
        key = paste0("story-frame-", as.numeric(Sys.time()))
      )
    })
  })

  # Modified download handler
  output$download_html <- downloadHandler(
    filename = function() {
      "generated_story.html"
    },
    content = function(file) {
      story_file <- file.path(session_temp_dir, "example.html")
      if (file.exists(story_file)) {
        file.copy(story_file, file)
      } else {
        stop("No story has been generated yet")
      }
    }
  )
}
