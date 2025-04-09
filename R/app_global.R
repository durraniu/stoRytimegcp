
# brand.yml ---------------------------------------------------------------

path_to_brand_yml <- "inst/brand/_brand.yml"
theme <- bslib::bs_theme(brand = path_to_brand_yml)
brand <- attr(theme, "brand")


app_name <- brand$meta$name$short
app_desc <- brand$meta$description

