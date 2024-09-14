#' The application User-Interface
#'
#' @param request Internal parameter for `{shiny}`.
#'     DO NOT REMOVE.
#' @import shiny
#' @import bslib
#' @noRd
app_ui <- function(request) {
  tagList(
    # Leave this function for adding external resources
    golem_add_external_resources(),
    # Your application UI logic
    page_fluid(
      theme = bs_theme(version = 5, bootswatch = "darkly"),

      layout_columns(
        col_widths = breakpoints(
          sm = c(12),
          md = c(12),
          lg = c(3, 9)
        ),
        card(
          card_header("Settings"),
          textAreaInput(
            "story_prompt",
            label = "Write the first sentence of your story:",
            width = "100%",
            height = "100px"
          ),
          numericInput("num_of_sentences",
                       label = "Number of sentences:",
                       value = 5, min = 2, max = 10),
          textAreaInput(
            "drawing_instructions",
            label = "Instructions for drawing images:",
            value = drawing_instructions,
            width = "100%",
            height = "200px"
          ),
          input_task_button("create_story", "Create Story")
        ),

        card(
          card_header(
            "Story",
            popover(
              placement = "right",
              bsicons::bs_icon("gear", class = "ms-auto"),
              selectInput(
                "story_theme",
                label = "Select theme:",
                choices = c("dark", "beige", "blood", "league", "moon", "night",
                            "serif", "simple", "sky", "solarized", "default")
              ),
              textInput(
                "story_title",
                label = "Provide a story title:",
                value = "stoRy time with shiny and quarto"
              ),
              input_task_button("update_theme", "Update Theme"),
              title = "Presentation settings"
            ),
            class = "d-flex align-items-center gap-1"
          ),
          htmlOutput("html_story"), min_height = 600
        )

      )
    )
  )
}

#' Add external Resources to the Application
#'
#' This function is internally used to add external
#' resources inside the Shiny application.
#'
#' @import shiny
#' @importFrom golem add_resource_path activate_js favicon bundle_resources
#' @noRd
golem_add_external_resources <- function() {
  add_resource_path(
    "www",
    app_sys("app/www")
  )

  tags$head(
    favicon(),
    bundle_resources(
      path = app_sys("app/www"),
      app_title = "stoRytimegcp"
    ),
    # Add here other external resources
    # for example, you can add shinyalert::useShinyalert()
    shinyalert::useShinyalert(force = TRUE)
  )
}
