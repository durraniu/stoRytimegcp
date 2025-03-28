test_that("get_story handles invalid inputs", {
  expect_null(get_story(NULL))
  expect_null(get_story("Snow white opened the door", num_of_sentences = 2))
})


bad_words <- unique(tolower(c(
  lexicon::profanity_alvarez,
  lexicon::profanity_arr_bad,
  lexicon::profanity_banned,
  lexicon::profanity_zac_anger,
  lexicon::profanity_racist
)))

# Escape any special characters in the bad words list
bad_words_escaped <- stringr::str_replace_all(bad_words, "([.\\+*?\\[\\^\\]$(){}=!<>|:-])", "\\\\\\1")

test_that("get_story returns NULL for profane prompts", {
  expect_null(get_story(sample(bad_words_escaped, 1)))
})


with_mock_dir("cfgsp", {
  test_that("get_story returns story when API response is successful", {
    res <- get_story("Snow white opened the door")

    expect_type(res, "character")
    # expect_equal(length(res), 5)
  })
})


