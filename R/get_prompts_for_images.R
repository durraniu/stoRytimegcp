#' Request story from API
#'
#' @param story Vector of story
#' @param max_tokens Max number of tokens
#' @param ACCOUNT_ID Cloudflare Workers AI Model API account ID
#' @param API_KEY  Cloudflare Workers AI Model API key
#' @param base_url Base URL of Workers AI Model API
#'
#' @return Character vector with multiple sentences.
get_prompts_for_images <- function(story,
                      max_tokens = 1000,
                      ACCOUNT_ID = Sys.getenv("ACCOUNT_ID"),
                      API_KEY = Sys.getenv("API_KEY"),
                      base_url = cf_base_url()){

  if (is.null(story) | length(story) == 0){
    return(NULL)
  }
  # url_txt <- paste0(base_url, ACCOUNT_ID, "/ai/run/@cf/meta/llama-3.1-8b-instruct-fast")
  url_txt <- paste0(base_url, ACCOUNT_ID, "/ai/run/@cf/meta/llama-3.3-70b-instruct-fp8-fast")


  # Make an API request
  response_prompts <- httr2::request(url_txt) |>
    httr2::req_headers(
      "Authorization" = paste("Bearer", API_KEY)
    ) |>
    httr2::req_body_json(list(
      max_tokens = max_tokens,
      messages = list(
        list(role = "system",
             content = paste0(
               "You write detailed prompts for generating images when story text is provided to you. The story contains ",
               length(story), " sentences. Each story sentence ends with a period. Write a detailed prompt for each story sentence that describes the scene and characters. A text to image generation model, stable diffusion XL, will then use your prompt to draw an image. Each prompt should include the physical traits of the subject(s) and object(s) of the sentence, the facial expressions of the subject(s) and object(s) (if needed), what the subject(s) are doing and what the subject(s) are wearing, the background, etc. The physical traits of the subjects and objects must be identical in all prompts  so that the model draws the same character in each image. Use commas for building a prompt per sentence. There should be one sentence containing the prompt per one sentence of the story. Each prompt must contain all the relevant details and should not refer to a previous prompt. Return the prompt sentences only. The number of sentences of prompts you return must be equal to the number of sentences of the story."
             )),
        list(
          role = "user",
          content = paste(story, collapse = " ")
        )
      ))) |>
    httr2::req_method("POST") |>
    httr2::req_error(is_error = \(resp) FALSE) |>
    httr2::req_perform() |>
    httr2::resp_body_json()


  # If response is successful, append it to the user prompt
  # clean it, and split the text into 5 sentences
  if (isTRUE(response_prompts$success)){
    full_text <- response_prompts$result$response
    cleaned_text <- gsub("\n", " ", full_text)
    split_text <- unlist(strsplit(cleaned_text, "(?<!\\b(?:Dr|Mr|Mrs|Ms|St|Jr|Sr|vs|etc|U\\.S))(?<=\\.)\\s+(?=[A-Z])", perl = TRUE))
  } else {
    split_text <- NULL
  }
  split_text
}
