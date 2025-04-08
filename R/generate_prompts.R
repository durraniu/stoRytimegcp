#' Get prompt and negative prompt based on style
#'
#' @param response_prompts Vector of prompts for generating images
#' @param style A character string specifying the desired style. Choices are:
#'   "anime", "comics", "lego_movie", "play_doh", "ethereal_fantasy", "isometric",
#'   "line_art", "origami", "pixel_art", "abstract", "impressionist",
#'   "renaissance", "watercolor", "biomechanical", "retro_futuristic",
#'   "fighting_game", "mario", "pokemon", "street_fighter", "horror",
#'   "manga", "space", "paper_mache", "tilt_shift".
#'
#' @returns List of prompt and negative prompt
generate_prompts <- function(response_prompts, style) {
  # Define style-specific prompt templates and negative prompts
  style_templates <- list(
    anime = list(
      prompt = "anime artwork {prompt} . anime style, key visual, vibrant, studio anime, highly detailed",
      negative_prompt = "photo, deformed, black and white, realism, disfigured, low contrast"
    ),
    comics = list(
      prompt = "comic book {prompt} . graphic illustration, comic art, graphic novel art, vibrant, highly detailed",
      negative_prompt = "photograph, deformed, glitch, noisy, realistic, stock photo"
    ),
    lego_movie = list(
      prompt = "lego movie {prompt} . graphic illustration, lego art, vibrant, highly detailed",
      negative_prompt = "photograph, deformed, glitch, noisy, realistic, stock photo"
    ),
    play_doh = list(
      prompt = "play-doh style {prompt} . sculpture, clay art, centered composition, Claymation",
      negative_prompt = "sloppy, messy, grainy, highly detailed, ultra textured, photo"
    ),
    ethereal_fantasy = list(
      prompt = "ethereal fantasy concept art of {prompt} . magnificent, celestial, ethereal, painterly, epic, majestic, magical, fantasy art, cover art, dreamy",
      negative_prompt = "photographic, realistic, realism, 35mm film, dslr, cropped, frame, text, deformed, glitch, noise, noisy, off-center, deformed, cross-eyed, closed eyes, bad anatomy, ugly, disfigured, sloppy, duplicate, mutated, black and white"
    ),
    line_art = list(
      prompt = "line art drawing {prompt} . professional, sleek, modern, minimalist, graphic, line art, vector graphics",
      negative_prompt = "anime, photorealistic, 35mm film, deformed, glitch, blurry, noisy, off-center, deformed, cross-eyed, closed eyes, bad anatomy, ugly, disfigured, mutated, realism, realistic, impressionism, expressionism, oil, acrylic"
    ),
    origami = list(
      prompt = "origami style {prompt} . paper art, pleated paper, folded, origami art, pleats, cut and fold, centered composition",
      negative_prompt = "noisy, sloppy, messy, grainy, highly detailed, ultra textured, photo"
    ),
    pixel_art = list(
      prompt = "pixel-art {prompt} . low-res, blocky, pixel art style, 8-bit graphics",
      negative_prompt = "sloppy, messy, blurry, noisy, highly detailed, ultra textured, photo, realistic"
    ),
    impressionist = list(
      prompt = "impressionist painting {prompt} . loose brushwork, vibrant color, light and shadow play, captures feeling over form",
      negative_prompt = "anime, photorealistic, 35mm film, deformed, glitch, low contrast, noisy"
    ),
    watercolor = list(
      prompt = "watercolor painting {prompt} . vibrant, beautiful, painterly, detailed, textural, artistic",
      negative_prompt = "anime, photorealistic, 35mm film, deformed, glitch, low contrast, noisy"
    ),
    biomechanical = list(
      prompt = "biomechanical style {prompt} . blend of organic and mechanical elements, futuristic, cybernetic, detailed, intricate",
      negative_prompt = "natural, rustic, primitive, organic, simplistic"
    ),
    retro_futuristic = list(
      prompt = "retro-futuristic {prompt} . vintage sci-fi, 50s and 60s style, atomic age, vibrant, highly detailed",
      negative_prompt = "contemporary, realistic, rustic, primitive"
    ),
    fighting_game = list(
      prompt = "fighting game style {prompt} . dynamic, vibrant, action-packed, detailed character design, reminiscent of fighting video games",
      negative_prompt = "peaceful, calm, minimalist, photorealistic"
    ),
    mario = list(
      prompt = "Super Mario style {prompt} . vibrant, cute, cartoony, fantasy, playful, reminiscent of Super Mario series",
      negative_prompt = "realistic, modern, horror, dystopian, violent"
    ),
    pokemon = list(
      prompt = "Pokemon style {prompt} . vibrant, cute, anime, fantasy, reminiscent of Pokemon series",
      negative_prompt = "realistic, modern, horror, dystopian, violent"
    ),
    street_fighter = list(
      prompt = "Street Fighter style {prompt} . vibrant, dynamic, arcade, 2D fighting game, highly detailed, reminiscent of Street Fighter series",
      negative_prompt = "3D, realistic, modern, photorealistic, turn-based strategy"
    ),
    horror = list(
      prompt = "horror-themed {prompt} . eerie, unsettling, dark, spooky, suspenseful, grim, highly detailed",
      negative_prompt = "cheerful, bright, vibrant, light-hearted, cute"
    ),
    manga = list(
      prompt = "manga style {prompt} . vibrant, high-energy, detailed, iconic, Japanese comic style",
      negative_prompt = "ugly, deformed, noisy, blurry, low contrast, realism, photorealistic, Western comic style"
    ),
    space = list(
      prompt = "space-themed {prompt} . cosmic, celestial, stars, galaxies, nebulas, planets, science fiction, highly detailed",
      negative_prompt = "earthly, mundane, ground-based, realism"
    ),
    tilt_shift = list(
      prompt = "tilt-shift photo of {prompt} . selective focus, miniature effect, blurred background, highly detailed, vibrant, perspective control",
      negative_prompt = "blurry, noisy, deformed, flat, low contrast, unrealistic, oversaturated, underexposed"
    )
  )

  if (!style %in% names(style_templates)) {
    stop("Invalid style. Choose from: ", paste(names(style_templates), collapse = ", "))
  }

  formatted_prompts <- unname(sapply(response_prompts, function(prompt) {
    gsub("{prompt}", paste0("{", prompt, "}"), style_templates[[style]]$prompt, fixed = TRUE)
  }))

  list(
    prompt = formatted_prompts,
    negative_prompt = style_templates[[style]]$negative_prompt
  )
}
