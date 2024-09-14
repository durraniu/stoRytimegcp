story_prompt <- "Once upon a time there was a baby dragon named Paha"

system.time(
 story <- get_story(story_prompt)
)

drawing_instructions <- "This scene should be illustrated in a storybook style with soft, pastel colors, whimsical and child-friendly illustrations with gentle lines. The image should evoke warmth and wonder, resembling hand-drawn artwork with simplicity and charm, like classic fairy tales."

image_prompt <- paste0(
  "The background information for this scene is: ",
  story_prompt,
  ". 
  ", 
  drawing_instructions
)

# inst2 <- "The scene should be a background image appropriate for a presentation slide. There should be no character in it."

# if (!is.null(story)){
#   png_img <- get_single_image(story[1], inst2)
# } else {
#   png_img <- NULL
# }
# 
# 
# magick::image_read(png_img)


reqs <- lapply(
  story,
  function(x){
    req_single_image(x, image_prompt)
  }
)

system.time(resps <- httr2::req_perform_parallel(reqs))

get_image <- function(response){
  if (response$status_code == 200){
    png_img <- httr2::resp_body_raw(response)
  } else{
    png_img <- NULL
  }
  png_img
}

all_imgs <- lapply(resps, get_image)

# magick::image_read(all_imgs[[5]])

# save(all_imgs, story, file = "example_data.rda")
