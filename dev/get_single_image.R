#' Get a single image
#'
#' @param prompt
#' @param instructions
#' @param ACCOUNT_ID
#' @param API_KEY
#' @param base_url
#'
#' @return
#' @export
#'
#' @examples
get_single_image <- function(prompt,
                             instructions,
                             ACCOUNT_ID = Sys.getenv("ACCOUNT_ID"),
                             API_KEY = Sys.getenv("API_KEY"),
                             base_url = cf_base_url()){

  url_img <- paste0("https://api.cloudflare.com/client/v4/accounts/", ACCOUNT_ID, "/ai/run/@cf/bytedance/stable-diffusion-xl-lightning")

  # Create the request
  response <- httr2::request(url_img) |>
    httr2::req_headers(
      "Authorization" = paste("Bearer", API_KEY)
    ) |>
    httr2::req_body_json(list(prompt = paste0(
      prompt, " ",
      instructions
      ))) |>
    httr2::req_method("POST") |>
    httr2::req_perform()

  if (response$status_code == 200){
    png_img <- httr2::resp_body_raw(response)
  } else{
    png_img <- NULL
  }
  png_img
}
