
<!-- README.md is generated from README.Rmd. Please edit that file -->

# `{stoRytimegcp}`

{stoRytimegcp} is a shiny app that creates and illustrates stories with
user inputs and AI models.

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

## About

If you want to run this app on your own, you’d need an account ID and
generate an API key on Cloudflare Workers AI to use their models API.
The API is free to use for models in beta. After you obtain the ID and
API key, clone this repo and add create a `.Renviron` file in the root
of the cloned repo. Add the ID and key to the environment file. Now you
are ready to run this app with `golem::run_dev()`or
`storytimegcp::run_app()`.

## Links
Google Cloud Run: https://storytime-209667139353.us-central1.run.app/  
Shiny Apps: https://umair.shinyapps.io/storytimegcp/
