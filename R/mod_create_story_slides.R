#' create_story_slides UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @import shiny
#' @import bslib
mod_create_story_slides_ui <- function(id) {
  ns <- NS(id)
  layout_columns(
    col_widths = breakpoints(
      sm = c(12),
      md = c(12),
      lg = c(3, 9)
    ),
    card(
      card_header("Settings"),
      textAreaInput(
        ns("story_prompt"),
        label = "Write here what you want the story to be about:",
        width = "100%",
        height = "100px"
      ),
      numericInput(ns("num_of_sentences"),
                   label = "How may sentences do you want in the story?",
                   value = 5, min = 3, max = 10
      ),
      # textAreaInput(
      #   "drawing_instructions",
      #   label = "Instructions for drawing images:",
      #   value = drawing_instructions,
      #   width = "100%",
      #   height = "200px"
      # ),
      selectInput(
        ns("drawing_instructions"),
        label = "Select the style for drawing images:",
        choices = c(
          "Anime" = "anime",
          "Comics" = "comics",
          "LEGO Movie" = "lego_movie",
          "Play-Doh" = "play_doh",
          "Ethereal Fantasy" = "ethereal_fantasy",
          "Line Art" = "line_art",
          "Origami" = "origami",
          "Pixel Art" = "pixel_art",
          "Impressionist" = "impressionist",
          "Watercolor" = "watercolor",
          "Biomechanical" = "biomechanical",
          "Retro-Futuristic" = "retro_futuristic",
          "Fighting Game" = "fighting_game",
          "Mario" = "mario",
          "Pokemon" = "pokemon",
          "Street Fighter" = "street_fighter",
          "Horror" = "horror",
          "Manga" = "manga",
          "Space" = "space",
          "Tilt Shift" = "tilt_shift"
        )
      ),
      textInput(
        ns("story_title"),
        label = "Provide a story title:",
        value = "stoRy time with shiny and quarto"
      ),
      bslib::input_switch(ns("aud_on"), "Include narration"),
      bslib::input_task_button(ns("create_story"), "Create Story")
    ),

    card(
      id = "story_card",
      card_header(
        "Story",
        popover(
          placement = "right",
          bsicons::bs_icon("gear", class = "ms-auto"),
          selectInput(
            selectize = FALSE,
            selected = "default",
            inputId = ns("story_theme"),
            label = "Select theme:",
            choices = c("dark", "beige", "blood", "league", "moon", "night",
                        "serif", "simple", "sky", "solarized", "default")
          ),
          bslib::input_task_button(ns("update_theme"), "Update Theme"),
          # actionButton("update_theme", "Update Theme"),
          title = "Presentation settings"
        ),
        class = "d-flex align-items-center gap-1"
      ),
      uiOutput(ns("html_story")),
      # downloadButton(ns("download_html"), "Download Story", class = "btn-primary"),
      uiOutput(ns("download_ui")),
      min_height = 600
    )

  )
}

#' create_story_slides Server Functions
#'
#' @noRd
mod_create_story_slides_server <- function(id){
  moduleServer(id, function(input, output, session){
    ns <- session$ns

    # Your application server logic
    story <- reactiveVal()
    all_imgs <- reactiveVal()
    all_auds <- reactiveVal()
    temp_html_val <- reactiveVal()

    # Dynamically serve the updated HTML file from the temp folder
    output$html_story <- renderUI({
      req(temp_html_val())
      # browser()
      if (is.null(temp_html_val())){
        return(tags$p("Waiting for the story..."))
      }
      # Check if the file exists before serving
      if (file.exists(app_sys(paste0("app/www/", temp_html_val())))) {
        tags$iframe(
          src = paste0("www/", temp_html_val()),
          width = "100%",
          height = 600
        )
      } else {
        tags$p("Waiting for the story...")
      }
    })





    # Create story text, image prompts, images and audios
    observeEvent(input$create_story, {
      req(input$story_prompt)

      html_files <- list.files(app_sys("app/www"), pattern = "\\.html$", full.names = TRUE)
      unlink(html_files)

      story(NULL)
      all_imgs(NULL)
      temp_html_val(NULL)

      # browser()

      if (input$aud_on){
        all_auds(NULL)
        main_msg <- "Creating story, images, and narration ..."
        last_msg <- "Story, images, and narration created!"
      } else {
        main_msg <- "Creating story and images ..."
        last_msg <- "Story and images created!"
      }
# browser()

      tryCatch({

        withProgress(message = main_msg, value = 0, {

          if (input$story_prompt == ""){
            stop("Please describe what you want the story to be about")
          }

            # Show progress increment
            incProgress(0.3, detail = "Generating story...")

            # Get story from Workers AI model
            new_story <- get_story(
              prompt = input$story_prompt,
              num_of_sentences = input$num_of_sentences
            )

            # Process the story
            if (is.null(new_story)){
              stop("Please avoid profanity")
            }

            if (length(new_story) != input$num_of_sentences){
              stop("Oops! The AI model failed to generate the correct length of story. Please refresh this page and try again.")
            }

            story(new_story)

            # Get prompts for images
            prompts <- get_prompts_for_images(new_story)


            # Increment progress for image generation
            incProgress(0.5, detail = "Generating images...")

            # Get images from Workers AI model
            list_of_images <- get_images(prompts, input$drawing_instructions)
            if (length(list_of_images) != length(new_story)){
              stop("Oops! The AI model failed to generate the correct number of images. Please refresh this page and try again.")
            }
            all_imgs(list_of_images)

            if (input$aud_on){
              # Increment progress for audio generation
              incProgress(0.8, detail = "Generating narration...")

              # Get speech from Workers AI model
              list_of_audio_binaries <- get_audio(new_story)
              if (length(list_of_audio_binaries) != length(new_story)){
                stop("Something went wrong. Please refresh and try again.")
              }
              all_auds(list_of_audio_binaries)
            }


            # Increment progress for slides generation
            incProgress(0.9, detail = "Generating slides...")

            # Create a temp directory
            temp_dir <- tempdir()

            if (input$aud_on){

              # Copy qmd from www folder to temp directory
              file.copy(app_sys("app/www/input_with_audio.qmd"), file.path(temp_dir, "input_with_audio.qmd"), overwrite = TRUE)

              # Path to the copied qmd file in the temp directory
              temp_qmd <- file.path(temp_dir, "input_with_audio.qmd")
              temp_html <- file.path(temp_dir, "input_with_audio.html")

              unique_html_filename <- paste0("story_", Sys.time() |> format("%Y%m%d%H%M%S"), ".html")
              final_path <- file.path(app_sys("app/www"), unique_html_filename)
              temp_html_val(unique_html_filename)

              create_slides(
                input_qmd = temp_qmd,
                theme = input$story_theme,
                title = input$story_title,
                prompt = input$story_prompt,
                story = story(),
                all_imgs(),
                all_auds()
              )

              file.copy(temp_html, final_path, overwrite = TRUE)
            } else {
              # Copy qmd from www folder to temp directory
              file.copy(app_sys("app/www/input.qmd"), file.path(temp_dir, "input.qmd"), overwrite = TRUE)

              # Path to the copied qmd file in the temp directory
              temp_qmd <- file.path(temp_dir, "input.qmd")
              temp_html <- file.path(temp_dir, "input.html")

              unique_html_filename <- paste0("story_", Sys.time() |> format("%Y%m%d%H%M%S"), ".html")
              final_path <- file.path(app_sys("app/www"), unique_html_filename)
              temp_html_val(unique_html_filename)

              create_slides(
                input_qmd = temp_qmd,
                theme = input$story_theme,
                title = input$story_title,
                prompt = input$story_prompt,
                story = story(),
                all_imgs(),
                FALSE
              )

              file.copy(temp_html, final_path, overwrite = TRUE)
            }


          incProgress(1, detail = last_msg)
        })

      },
      error = function(e){
        showNotification(conditionMessage(e), duration = NULL)
      })

    }, ignoreInit = TRUE)



    observeEvent(input$update_theme, {
      req(input$story_prompt, input$story_theme, story(), all_imgs())

      html_files <- list.files(app_sys("app/www"), pattern = "\\.html$", full.names = TRUE)
      unlink(html_files)


      tryCatch({

        withProgress(message = "Re-generating slides", value = 0, {

          # Create a temp directory
          temp_dir <- tempdir()

          if (input$aud_on){

            # Copy qmd from www folder to temp directory
            file.copy(app_sys("app/www/input_with_audio.qmd"), file.path(temp_dir, "input_with_audio.qmd"), overwrite = TRUE)

            # Path to the copied qmd file in the temp directory
            temp_qmd <- file.path(temp_dir, "input_with_audio.qmd")
            temp_html <- file.path(temp_dir, "input_with_audio.html")

            unique_html_filename <- paste0("story_", Sys.time() |> format("%Y%m%d%H%M%S"), ".html")
            final_path <- file.path(app_sys("app/www"), unique_html_filename)
            temp_html_val(unique_html_filename)

            create_slides(
              input_qmd = temp_qmd,
              theme = input$story_theme,
              title = input$story_title,
              prompt = input$story_prompt,
              story = story(),
              all_imgs(),
              all_auds()
            )

            file.copy(temp_html, final_path, overwrite = TRUE)
          } else {
            # Copy qmd from www folder to temp directory
            file.copy(app_sys("app/www/input.qmd"), file.path(temp_dir, "input.qmd"), overwrite = TRUE)

            # Path to the copied qmd file in the temp directory
            temp_qmd <- file.path(temp_dir, "input.qmd")
            temp_html <- file.path(temp_dir, "input.html")

            unique_html_filename <- paste0("story_", Sys.time() |> format("%Y%m%d%H%M%S"), ".html")
            final_path <- file.path(app_sys("app/www"), unique_html_filename)
            temp_html_val(unique_html_filename)

            create_slides(
              input_qmd = temp_qmd,
              theme = input$story_theme,
              title = input$story_title,
              prompt = input$story_prompt,
              story = story(),
              all_imgs(),
              FALSE
            )

            file.copy(temp_html, final_path, overwrite = TRUE)
          }


          incProgress(1, detail = "Done!")
        })

      },
      error = function(e){
        showNotification(conditionMessage(e), duration = NULL)
      })

    }, ignoreInit = TRUE)




    output$download_ui <- renderUI({
      req(temp_html_val())
      target_html <- app_sys(file.path("app/www/", temp_html_val()))

      if (file.exists(target_html)) {
        downloadButton(ns("download_html"), "Download Story", class = "btn-primary")
      } else {
        # tags$p("No story available for download yet.")
      }
    })



    output$download_html <- downloadHandler(
      filename = function() {
        "generated_story.html"
      },
      content = function(file) {
        target_html <- app_sys(paste0("app/www/", temp_html_val()))

        # Ensure the file exists before allowing the download
        if (file.exists(target_html)) {
          # Copy the generated HTML file to the specified download location
          file.copy(target_html, file)
        } else {
          showNotification("No story available for download yet.", type = "error")
        }
      }
    )
  })
}
