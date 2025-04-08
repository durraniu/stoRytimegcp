#' Create revealjs slides using quarto
#'
#' @param input_qmd Path to qmd file
#' @param theme Revealjs theme
#' @param title Story title
#' @param prompt Prompt for creating story
#' @param story Story text
#' @param images List of binary images
#' @param audios List of binary audios
#'
#' @returns Quarto revealjs slides
#' @export
create_slides <- function(input_qmd, theme, title, prompt, story, images, audios) {

  if (length(audios) == 1){
    return(
      quarto::quarto_render(
        input = input_qmd,
        output_format = "all",
        metadata = list(
          theme = theme,
          "title-slide-attributes" = list(
            "data-background-image" = paste0("data:image/png;base64,", base64enc::base64encode(utils::tail(images, 1)[[1]])),
            "data-background-size" = "cover",
            "data-background-opacity" = 0.3
          )
        ),
        quarto_args = c(
          "--metadata",
          paste0("title=", title)
        ),
        execute_params = list(
          story_prompt = prompt,
          story = story,
          imgs = lapply(images, base64enc::base64encode)
        ),
        quiet = TRUE
      )
    )
  }


  quarto::quarto_render(
    input = input_qmd,
    output_format = "all",
    metadata = list(
      theme = theme,
      "title-slide-attributes" = list(
        "data-background-image" = paste0("data:image/png;base64,", base64enc::base64encode(utils::tail(images, 1)[[1]])),
        "data-background-size" = "cover",
        "data-background-opacity" = 0.3
      )
    ),
    quarto_args = c(
      "--metadata",
      paste0("title=", title)
    ),
    execute_params = list(
      story_prompt = prompt,
      story = story,
      imgs = lapply(images, base64enc::base64encode),
      audios = lapply(audios, base64enc::base64encode)
    ),
    quiet = TRUE
  )
}
