#' Get all images corresponding to prompts
#'
#' @param response_prompts A vector of prompts that describe what to draw
#' @param style A character string specifying the desired style. Choices are:
#'   "anime", "comics", "lego_movie", "play_doh", "ethereal_fantasy", "isometric",
#'   "line_art", "origami", "pixel_art", "abstract", "impressionist",
#'   "renaissance", "watercolor", "biomechanical", "retro_futuristic",
#'   "fighting_game", "mario", "pokemon", "street_fighter", "horror",
#'   "manga", "space", "paper_mache", "tilt_shift".
#'
#' @returns List of raw images.
get_images <- function(response_prompts, style){
  image_prompts <- generate_prompts(response_prompts, style)

  if (is.null(image_prompts$prompt)){
    new_all_imgs <- NULL
  } else {
    reqs <- lapply(
      image_prompts$prompt,
      function(x){
        req_single_image(x, image_prompts$negative_prompt)
      }
    )
    resps <- httr2::req_perform_parallel(reqs, on_error = "continue")

    # All images
    new_all_imgs <- lapply(resps, get_raw_image)
  }
  new_all_imgs
}
