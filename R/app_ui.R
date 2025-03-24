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
      theme = bs_theme(
        bg = "#f8f9fa",
        fg = "#212529",
        primary = "#7952b3",
        secondary = "#ff85a2",
        success = "#28a745",
        info = "#17a2b8",
        warning = "#ffc107",
        danger = "#dc3545",
        base_font =  font_link(
          "ABeeZee",
          href = "https://fonts.bunny.net/css?family=abeezee:400"
        ),
        font_scale = 1.2,
        heading_font = font_link(
          "Bevan",
          href = "https://fonts.bunny.net/css?family=abeezee:400|bevan:400"
        )
      ),
        div(
          # class = "hero-section",
          style = css(`padding-top` = "40px"),
          layout_columns(
            col_widths = breakpoints(
              sm = c(-1, 10, -1),
              md = c(-1, 6, 4, -1)
            ),
          div(
            h1("CREATE", br(), "STORIES", br(), "WITH AI",
               class = "hero-title"
               ),
            p("Create beautiful and alive stories with text-generation and image-generation models!", class = "hero-text"),
            input_task_button("get_started2", "GET STARTED", class = "btn-lg")
          ),
          tags$img(src = "https://media3.giphy.com/media/v1.Y2lkPTc5MGI3NjExdzMzNHV6dGs4NnZtajdsbzZ4eTc3MjRrbWZoZG96MXM5ZmFtdHFrYyZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/SS40oFiyppsHhvClo2/giphy.gif"#,
                   # class = "hero-image"
                   )
        )
      )

      # layout_columns(
      #   col_widths = breakpoints(
      #     sm = c(12),
      #     md = c(12),
      #     lg = c(3, 9)
      #   ),
      #   card(
      #     card_header("Settings"),
      #     textAreaInput(
      #       "story_prompt",
      #       label = "Write the first sentence of your story:",
      #       width = "100%",
      #       height = "100px"
      #     ),
      #     numericInput("num_of_sentences",
      #                  label = "Number of sentences:",
      #                  value = 5, #min = 3, max = 10
      #                  ),
      #     textAreaInput(
      #       "drawing_instructions",
      #       label = "Instructions for drawing images:",
      #       value = drawing_instructions,
      #       width = "100%",
      #       height = "200px"
      #     ),
      #     textInput(
      #       "story_title",
      #       label = "Provide a story title:",
      #       value = "stoRy time with shiny and quarto"
      #     ),
      #     bslib::input_task_button("create_story", "Create Story")
      #     # actionButton("create_story", "Create Story")
      #   ),
      #
      #   card(
      #     id = "story_card",
      #     card_header(
      #       "Story",
      #       popover(
      #         placement = "right",
      #         bsicons::bs_icon("gear", class = "ms-auto"),
      #         selectInput(
      #           selectize = FALSE,
      #           "story_theme",
      #           label = "Select theme:",
      #           choices = c("dark", "beige", "blood", "league", "moon", "night",
      #                       "serif", "simple", "sky", "solarized", "default")
      #         ),
      #         bslib::input_task_button("update_theme", "Update Theme"),
      #         # actionButton("update_theme", "Update Theme"),
      #         title = "Presentation settings"
      #       ),
      #       class = "d-flex align-items-center gap-1"
      #     ),
      #     htmlOutput("html_story"),
      #     downloadButton("download_html", "Download Story"),
      #     min_height = 600
      #   )
      #
      # )
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
    # shinyalert::useShinyalert(force = TRUE),
    useBusyIndicators(),
    # waiter::useWaiter(), # include dependencies
    # htmltools::findDependencies(selectInput("test", "test", NULL)),
    # shiny.telemetry::use_telemetry(),
    tags$script(HTML('
      $(document).on("click", "#create_story", function() {
        $("html, body").animate({
          scrollTop: $("#story_card").offset().top
        }, 1000);
      });
    '))
  )
}
