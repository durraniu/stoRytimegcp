#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @import slickR
#' @noRd
app_server <- function(input, output, session) {

  #--**********************************************
  # Sentry settings -----
  ## Sentry is a service that is used to monitor
  ## application errors, handled by {sentryR}.
  ## An issue will be created on the sentry account
  ## whenever an error occurs in shiny.
  #--**********************************************
  ## Set up an isolated environment
  sentryR::configure_sentry(
    dsn = Sys.getenv("SENTRY_KEY"),
    app_name = "stoRytime",
    app_version = "1.0.0"
  )
  ## Function to safely get browser info
  get_browser_info <- function() {
    tryCatch(
      {
        user_agent <- session$request$HTTP_USER_AGENT # browser
        remote_addr <- session$request$REMOTE_ADDR # ip
        list(
          user_agent = if (is.null(user_agent)) "Unknown" else user_agent,
          remote_addr = if (is.null(remote_addr)) "Unknown" else remote_addr
        )
      },
      error = function(e) {
        list(
          user_agent = paste("Error getting user agent:", e$message),
          remote_addr = paste("Error getting IP:", e$message)
        )
      }
    )
  }

  error_handler <- function() {
    tryCatch(
      {
        e <- get("e", envir = parent.frame())

        stack_trace <- shiny::printStackTrace(e) |>
          utils::capture.output(type = "message") |>
          list()

        browser <- get_browser_info()
        # Send the original error object with additional context as extra
        sentryR::capture(
          message = geterrmessage(),
          extra = list(
            Browser = browser$user_agent,
            IP = browser$remote_addr,
            "Stack trace" =  stack_trace
          )
        )
      },
      error = function(e) {
        print(paste("Error in error handler:", e$message))
      }
    )
  }


  #--****************************************
  # Shiny options -----
  #--****************************************
  options(
    # spinner.color = brand$color$primary, #skyline_blue,
    shiny.error = error_handler
  )


  #--**********************************************
  # Carousel -----
  ## Show image carousel in the hero section
  #--**********************************************

  output$s <- renderSlickR({
    x <- slickR(obj = paste0("inst/app/www/images/", list.files("inst/app/www/images/")), slideId = "slick1")
    x + settings(dots = TRUE, autoplay = TRUE, autoplaySpeed = 1000)
  })


  #--**********************************************
  # Revealjs slide deck -----
  #--**********************************************
  mod_create_story_slides_server("main")

}
