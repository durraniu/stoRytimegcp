#' Convert text to speech
#'
#' @param text Text to be converted to speech
#' @param ACCOUNT_ID Cloudflare Workers AI Model API account ID
#' @param API_KEY Cloudflare Workers AI Model API key
#' @param base_url Base URL of Workers AI Model API
#'
#' @returns Audio in binary.
get_audio <- function(text,
                      ACCOUNT_ID = Sys.getenv("ACCOUNT_ID"),
                      API_KEY = Sys.getenv("API_KEY"),
                      base_url = cf_base_url()){

  url_audio <- paste0(base_url, ACCOUNT_ID, "/ai/run/@cf/myshell-ai/melotts")

  req <- httr2::request(url_audio) |>
    httr2::req_headers(
      "Authorization" = paste("Bearer", API_KEY)
    ) |>
    httr2::req_body_json(list(
      prompt = text
    )) |>
    httr2::req_method("POST")

  res <- req |>
    httr2::req_perform() |>
    httr2::resp_body_json()

  if (isTRUE(res$success)){
    aud <- base64enc::base64decode(res$result$audio)
  } else {
    aud <- NULL
  }

  aud
}
