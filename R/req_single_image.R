#' Request a single image from API
#'
#' @param prompt Description of image
#' @param instructions Instructions for image drawing
#' @param ACCOUNT_ID Cloudflare Workers AI Model API account ID
#' @param API_KEY Cloudflare Workers AI Model API key
#' @param base_url Base URL of Workers AI Model API
#'
#' @return Request.
req_single_image <- function(prompt,
                             instructions,
                             ACCOUNT_ID = Sys.getenv("ACCOUNT_ID"),
                             API_KEY = Sys.getenv("API_KEY"),
                             base_url = cf_base_url()){

  url_img <- paste0("https://api.cloudflare.com/client/v4/accounts/", ACCOUNT_ID, "/ai/run/@cf/bytedance/stable-diffusion-xl-lightning")

  # Create the request
  httr2::request(url_img) |>
    httr2::req_headers(
      "Authorization" = paste("Bearer", API_KEY)
    ) |>
    httr2::req_body_json(list(prompt = paste0(
      prompt, " ",
      instructions
    ))) |>
    httr2::req_method("POST")
}



#' Get image if request is successful
#'
#' @param response Response from Workers AI Model API
#'
#' @return Image or NULL.
get_image <- function(response){
  if (response$status_code == 200){
    png_img <- httr2::resp_body_raw(response)
  } else{
    png_img <- NULL
  }
  png_img
}
