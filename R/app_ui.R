#' The application User-Interface
#'
#' @param request Internal parameter for `{shiny}`.
#'     DO NOT REMOVE.
#' @import shiny
#' @import bslib
#' @import slickR
#' @noRd
app_ui <- function(request) {
  tagList(
    # Leave this function for adding external resources
    golem_add_external_resources(),
    # Your application UI logic
    page_fluid(
      theme = bs_theme(
        # bootswatch = "vapor",
        bg = "#ffffff",
        fg = "#61212D",
        primary = "#61212D",
        secondary = "#03A9F4",
        success = "#4CAF50",
        info = "#00BCD4",
        warning = "#FFC107",
        danger = "#E91E63",
        base_font =  font_link(
          "ABeeZee",
          href = "https://fonts.bunny.net/css?family=abeezee:400"
        ),
        font_scale = 1.2,
        heading_font = font_link(
          "Architects Daughter",
          href = "https://fonts.bunny.net/css?family=architects-daughter:400"
        )
      ),
      create_hero_section(
        title = "Create Stories With AI",
        subtitle = "Create beautiful and alive stories with text-generation and image-generation models!"
      ),

      br(),
      br(),
      hr(),
      br(),
      br(),

      mod_create_story_slides_ui("main")

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
    useBusyIndicators()
  )
}
