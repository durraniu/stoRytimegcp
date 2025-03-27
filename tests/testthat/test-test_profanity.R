bad_words <- unique(tolower(c(
  lexicon::profanity_alvarez,
  lexicon::profanity_arr_bad,
  lexicon::profanity_banned,
  lexicon::profanity_zac_anger,
  lexicon::profanity_racist
)))

# Escape any special characters in the bad words list
bad_words_escaped <- stringr::str_replace_all(bad_words, "([.\\+*?\\[\\^\\]$(){}=!<>|:-])", "\\\\\\1")

test_that("test_profanity detects profane words", {
  expect_true(test_profanity(sample(bad_words_escaped, 1)))
  expect_true(test_profanity(sample(bad_words_escaped, 1)))
  expect_true(test_profanity(sample(bad_words_escaped, 1)))
})

test_that("test_profanity does not detect non-profane words", {
  expect_false(test_profanity("This is a clean sentence."))
  expect_false(test_profanity("Completely inoffensive text."))
})

test_that("test_profanity is case insensitive", {
  expect_true(test_profanity(toupper(sample(bad_words_escaped, 1))))
})

test_that("test_profanity detects words with punctuation", {
  expect_true(test_profanity(paste0(sample(bad_words_escaped, 1), "!")))
  expect_true(test_profanity(paste0("@", sample(bad_words_escaped, 1), ".")))
})
