test_that("generate_prompts returns correct structure", {
  result <- generate_prompts(c("a castle", "a dragon"), "anime")
  expect_type(result, "list")
  expect_named(result, c("prompt", "negative_prompt"))
  expect_type(result$prompt, "character")
  expect_type(result$negative_prompt, "character")
})

test_that("generate_prompts returns correct negative prompt", {
  result <- generate_prompts("a warrior", "horror")
  expect_equal(result$negative_prompt, "cheerful, bright, vibrant, light-hearted, cute")
})


test_that("generate_prompts throws error for invalid style", {
  expect_error(generate_prompts("a castle", "invalid_style"), "Invalid style")
})
