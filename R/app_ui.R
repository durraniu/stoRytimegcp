#' The application User-Interface
#'
#' @param request Internal parameter for `{shiny}`.
#'     DO NOT REMOVE.
#' @import shiny
#' @import bslib
#' @import slickR
#' @noRd
app_ui <- function(request) {

  path_to_brand_yml <- app_sys("brand/_brand.yml")

  tagList(
    # Leave this function for adding external resources
    golem_add_external_resources(),
    # Your application UI logic
    page_fluid(
      theme = bslib::bs_theme(brand = path_to_brand_yml),

      navset_bar(
        id = "nav_pages",
        title = "Create Stories with AI",
        navbar_options = navbar_options(position = "fixed-bottom"),
        # nav_spacer(),
        # Main
        nav_panel(
          "Create Stories",
          create_hero_section(
            title = paste0(app_name, ": Create Stories With AI"),
            subtitle = app_desc
          ),
          hr(),
          mod_create_story_slides_ui("main"),
          div(style = "margin-bottom: 50px;")
        ),
        # Saved stories
        nav_panel(
          "Explore",
          layout_column_wrap(
            width = 1/2,
            mod_download_stories_ui("apocalypse", "Apocalypse"),
            mod_download_stories_ui("dracula", "Dracula"),
            mod_download_stories_ui("future", "Future"),
            mod_download_stories_ui("harry_potter_dream", "Harry Potter Dream"),
            mod_download_stories_ui("narnia", "Narnia")
          )
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
#' @importFrom shinyjs useShinyjs
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
    useBusyIndicators(),
    useShinyjs()
  )
}
