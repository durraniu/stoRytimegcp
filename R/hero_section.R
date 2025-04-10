#' Create hero section of the homepage
#'
#' @param title Title of the app
#' @param subtitle Subtitle of the app
#'
#' @returns Div.
create_hero_section <- function(title, subtitle){
  div(
    class = "hero-section",
    layout_columns(
      col_widths = breakpoints(
        sm = c(-1, 10, -1),
        md = c(-1, 5, 5, -1)
      ),
      div(
        h1(title, class = "hero-title"),
        p(subtitle, class = "hero-text"),
        input_task_button("get_started", "GET STARTED", class = "btn-lg", onclick = "scrollToCards()")
      ),
      slickROutput("s")
    )
  )
}
