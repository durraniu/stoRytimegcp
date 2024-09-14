#' @title Test for profanity in a string (from One4All package)
#'
#' @description This function checks if the input string contains any profane words.
#'
#' @param x A character string to check for profanity.
#' @return A logical value indicating whether the input string contains no profane words.
#' @import lexicon
#' @import stringr
test_profanity <- function(x){
  bad_words <- unique(tolower(c(
    lexicon::profanity_alvarez,
    lexicon::profanity_arr_bad,
    lexicon::profanity_banned,
    lexicon::profanity_zac_anger,
    lexicon::profanity_racist
  )))
  # Escape any special characters in the bad words list
  bad_words_escaped <- stringr::str_replace_all(bad_words, "([.\\+*?\\[\\^\\]$(){}=!<>|:-])", "\\\\\\1")

  # Check if any bad words are found in the input string
  vapply(bad_words_escaped, function(y) {
    !stringr::str_detect(x, y)
  }, FUN.VALUE = TRUE) |>
    all()
}
