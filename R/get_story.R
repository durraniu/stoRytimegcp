#' Request story from API
#'
#' @param prompt Description of story
#' @param num_of_sentences Number of sentences in the story
#' @param max_tokens Max number of tokens
#' @param ACCOUNT_ID Cloudflare Workers AI Model API account ID
#' @param API_KEY  Cloudflare Workers AI Model API key
#' @param base_url Base URL of Workers AI Model API
#'
#' @return Character vector with multiple sentences.
get_story <- function(prompt,
                      num_of_sentences = 5,
                      max_tokens = 1000,
                      ACCOUNT_ID = Sys.getenv("ACCOUNT_ID"),
                      API_KEY = Sys.getenv("API_KEY"),
                      base_url = cf_base_url()){

  if (is.null(prompt) | num_of_sentences < 3){
    return(NULL)
  }

  if (test_profanity(prompt)){
    return(NULL)
  }

  url_txt <- paste0(base_url, ACCOUNT_ID, "/ai/run/@cf/meta/llama-3.1-8b-instruct-fast")
  # url_txt <- paste0(base_url, ACCOUNT_ID, "/ai/run/@cf/meta/llama-3.3-70b-instruct-fp8-fast")

  # message("Sending request to get story with", API_KEY, " and ", ACCOUNT_ID)

  # Make an API request
  response_text <- httr2::request(url_txt) |>
    httr2::req_headers(
      "Authorization" = paste("Bearer", API_KEY)
    ) |>
    httr2::req_body_json(list(
      max_tokens = max_tokens,
      messages = list(
        list(role = "system",
             content = paste0("You tell long stories for children when given a prompt.
             Each sentence must describe all details.",
             "The story must have a beginning, a climax and an end.",
             # "The story must follow the three-act structure model, i.e., it must have the Setup, the Confrontation, and the Resolution.",
             "For example, if the prompt is 'Snow white opened the door', the result is detailed, something like: 'Once upon a time, in a far-off kingdom hidden behind a veil of sparkling mist and surrounded by towering mountains that touched the sky, Snow White opened the door to a small, cozy cottage that was nestled among the tall trees, its roof covered in a thick layer of snow that glistened like a thousand tiny diamonds in the warm sunlight. As she stepped inside, she was greeted by the warm smile of an old woman who was sitting by the fireplace, stirring a big pot of steaming hot soup that filled the air with the delicious aroma of freshly baked bread and roasting vegetables, making Snow White's stomach growl with hunger. The old woman, who introduced herself as Granny, welcomed Snow White with open arms and invited her to sit down at the wooden table, where a beautiful feast was laid out, complete with golden plates, sparkling glasses, and a delicious-looking cake that was adorned with colorful flowers and candies. But just as Snow White was about to take a bite of the cake, a loud knock at the door interrupted the peaceful atmosphere, and Granny's face turned pale as she whispered to Snow White that it was the wicked queen, who had been searching for Snow White everywhere and would stop at nothing to catch her. In the end, Snow White and Granny were able to outsmart the wicked queen by disguising Snow White as an old hag, and they lived happily ever after, surrounded by the beauty and magic of the enchanted forest, where animals talked and flowers bloomed in every color of the rainbow.'",
             "If appropriate, start the story with 'Once upon a time'.",
             "The story must have ",  num_of_sentences,  " sentences."
            )),
        list(
          role = "user",
          content = prompt
        )
      ))) |>
    httr2::req_method("POST") |>
    httr2::req_error(is_error = \(resp) FALSE) |>
    httr2::req_perform() |>
    httr2::resp_body_json()

  # message("trying msg", API_KEY, " and ", ACCOUNT_ID)

  # If response is successful, append it to the user prompt
  # clean it, and split the text into 5 sentences
  if (isTRUE(response_text$success)){
    full_text <- response_text$result$response #paste(prompt, response_text$result$response)
    cleaned_text <- gsub("\n", "", full_text)
    split_text <- unlist(strsplit(cleaned_text, "(?<!\\b(?:Dr|Mr|Mrs|Ms|St|Jr|Sr|vs|etc|U\\.S))(?<=\\.)\\s+(?=[A-Z])", perl = TRUE))
  } else {
    split_text <- NULL
  }

  # c(prompt, split_text)
  split_text
}
