
# brand.yml ---------------------------------------------------------------

path_to_brand_yml <- "inst/brand/_brand.yml"
theme <- bslib::bs_theme(brand = path_to_brand_yml)
brand <- attr(theme, "brand")


app_name <- brand$meta$name$short
app_desc <- brand$meta$description


# Function for downloading stories ----------------------------------------

download_and_render_html <- function(url){
  response <- httr2::request(url) |>
    httr2::req_perform()
  if (httr2::resp_status(response) == 200) {
    html_content <- httr2::resp_body_string(response, encoding = "UTF-8")
  }
}
