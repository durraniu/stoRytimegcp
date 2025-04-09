#' download_stories UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @import shiny
#' @import bslib
mod_download_stories_ui <- function(id, title) {
  ns <- NS(id)
  card(
    height = 400,
    full_screen = TRUE,
    card_header(
      title,
      input_task_button(
        ns("downloadBtn"),
        label = "Download and Display",
        class = "btn-sm btn-primary"
      )
    ),
    card_body(
      tags$iframe(
        id = paste0("htmlFrame", id),
        style = "width: 100%; height: 100%; border: none;"
      )
    )
  )
}

#' download_stories Server Functions
#'
#' @noRd
mod_download_stories_server <- function(id, title, html_file){
  moduleServer(id, function(input, output, session){
    ns <- session$ns
    base_url <- "https://raw.githubusercontent.com/durraniu/examples-storytime/refs/heads/main/htmls/"


    observeEvent(input$downloadBtn, {
      # Complete URL for this HTML file
      url <- paste0(base_url, html_file)

      # Download the HTML content
      html_content <- download_and_render_html(url)

      showNotification(paste0("Rendering ", title, "..."), type = "message", duration = 2)

      # Set the iframe source to display the HTML content
      js_code <- sprintf('
          var iframe = document.getElementById("htmlFrame%s");
          iframe.srcdoc = %s;
        ', id, jsonlite::toJSON(html_content))

      shinyjs::runjs(js_code)
    })

  })
}
