#' Convert text to speech via Google
#'
#' @param text text to convert to speech
#' @param token auth token
#' @param name name of AI model
#'
#' @return
#' @export
#'
#' @examples
convert_text_to_speech <- function(text, token, name = "en-US-Journey-F"){
  request_body <- list(
    input = list(
      text = text
    ),
    voice = list(
      languageCode = "en-US",
      name = name,
      ssmlGender = "FEMALE"
    ),
    audioConfig = list(
      audioEncoding = "MP3"
    )
  )

  req_speech <- httr2::request("https://texttospeech.googleapis.com/v1/text:synthesize") |>
    httr2::req_method("POST") |>
    httr2::req_headers(
      Authorization = paste0("Bearer ", token),
      `Content-Type` = "application/json; charset=utf-8",
      `x-goog-user-project` = Sys.getenv("PROJECT_ID"),
    ) |>
    httr2::req_body_json(request_body) |>
    httr2::req_perform()

  speech <- req_speech |>
    httr2::resp_body_json()
  speech

  # speech_binary <- base64enc::base64decode(speech$audioContent)
  # output_file <- paste0(output, ".mp3")
  # writeBin(speech_binary, output_file)
}
