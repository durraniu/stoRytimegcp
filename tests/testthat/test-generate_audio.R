test_that("get_audio handles NULL input", {
  expect_null(get_audio(NULL))
})


with_mock_dir("cfga", {
  test_that("get_audio returns audio when API response is successful", {
    res <- get_story("Snow white opened the door")
    audio_output <- get_audio(res)

    # Check if the output is raw binary data
    expect_true(is.list(audio_output))
    expect_equal(length(audio_output), length(res))
  })
})
