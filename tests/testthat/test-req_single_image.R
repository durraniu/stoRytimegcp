test_that("req_single_image constructs a valid request", {
  req <- req_single_image(
    prompt = "A futuristic cityscape",
    negative_prompt = "Low resolution, blurry"
  )

  expect_s3_class(req, "httr2_request")
  expect_equal(req$method, "POST")
})

test_that("req_single_image fails with missing required arguments", {
  expect_error(req_single_image(), "argument \"prompt\" is missing")
  expect_error(req_single_image(prompt = "A cat"), "argument \"negative_prompt\" is missing")
})
