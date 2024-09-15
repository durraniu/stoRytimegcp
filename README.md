
<!-- README.md is generated from README.Rmd. Please edit that file -->

# `{stoRytimegcp}`

{stoRytimegcp} is a shiny app that creates and illustrates stories with
user inputs and AI models.

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

## About

You’d need an account ID and generate an API key on Cloudflare Workers
AI to use their models API. The API is free to use for models in beta.
After you obtain the ID and API key, clone this repo and add create a
`.Renviron` file in the root of the cloned repo. Add the ID and key to
the environment file. Now you are ready to run this app with
`golem::run_dev()`or `storytimegcp::run_app()`

You are reading the doc about version : 0.0.0.9000

This README has been compiled on the

``` r
Sys.time()
#> [1] "2024-09-15 11:44:47 EDT"
```

Here are the tests results and package coverage:

``` r
devtools::check(quiet = TRUE)
#> ℹ Loading storytimegcp
#> ── R CMD check results ──────────────────────────── storytimegcp 0.0.0.9000 ────
#> Duration: 38.1s
#> 
#> ❯ checking dependencies in R code ... NOTE
#>   Namespace in Imports field not imported from: 'pkgload'
#>     All declared Imports should be used.
#> 
#> 0 errors ✔ | 0 warnings ✔ | 1 note ✖
```

``` r
covr::package_coverage()
#> Warning: package 'storytimegcp' is in use and will not be installed
#> Warning in file(con, "r"): cannot open file
#> 'C:/Users/umair/AppData/Local/Temp/Rtmpu8KVMP/R_LIBS843452894f43/storytimegcp/R/storytimegcp':
#> No such file or directory
#> Error in file(con, "r"): cannot open the connection
```
