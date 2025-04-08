#' Convert text to speech
#'
#' @param text Text to be converted to speech
#' @param ACCOUNT_ID Cloudflare Workers AI Model API account ID
#' @param API_KEY Cloudflare Workers AI Model API key
#' @param base_url Base URL of Workers AI Model API
#'
#' @returns httr2 request.
get_audio_req <- function(text,
                      ACCOUNT_ID = Sys.getenv("ACCOUNT_ID"),
                      API_KEY = Sys.getenv("API_KEY"),
                      base_url = cf_base_url()){

  if (is.null(text)){
    return(NULL)
  }

  url_audio <- paste0(base_url, ACCOUNT_ID, "/ai/run/@cf/myshell-ai/melotts")

  req <- httr2::request(url_audio) |>
    httr2::req_headers(
      "Authorization" = paste("Bearer", API_KEY)
    ) |>
    httr2::req_body_json(list(
      prompt = text
    )) |>
    httr2::req_method("POST")

  req
}



#' Extract Raw Audio
#'
#' @param res API response
#'
#' @returns Audio in binary.
get_raw_audio <- function(res){
  if (res$status_code == 200){
    resp <- httr2::resp_body_json(res)
    aud <- base64enc::base64decode(resp$result$audio)
  } else {
    aud <- NULL
  }
  aud
}

#' Get audio from text
#'
#' @param text Vector of story text
#'
#' @returns List of audio in binary.
get_audio <- function(text){
  if (is.null(text) || length(text) == 0) {
    return(NULL)
  }
  reqs <- lapply(text, get_audio_req)
  resps <- lapply(reqs, httr2::req_perform)
  # resps <- httr2::req_perform_parallel(reqs, on_error = "continue")
  # All audio
  auds <- tryCatch({
    lapply(resps, get_raw_audio)
  }, error = function(e) {
    NULL
  })
  auds
}
