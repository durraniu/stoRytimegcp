test_that("get_prompts_for_images handles invalid inputs", {
  expect_null(get_prompts_for_images(NULL))
  expect_null(get_prompts_for_images(character(0)))
})

with_mock_dir("cfgpi", {
  test_that("get_prompts_for_images returns prompts when API response is successful", {
    story <- get_story("Snow white opened the door")
    response_prompts <- get_prompts_for_images(story)

    expect_type(response_prompts, "character")
    expect_equal(length(response_prompts), 5)
    expect_true(all(nzchar(response_prompts)))
  })
})
