# configure_shinyapps.R
# Script to configure shinyapps.io authentication

library(rsconnect)

# Function to configure shinyapps.io account
configure_shinyapps <- function(account_name = NULL, token = NULL, secret = NULL) {
  # Check if credentials are provided
  if (is.null(account_name) || is.null(token) || is.null(secret)) {
    message("Please provide your shinyapps.io credentials.")
    message("You can find these in your shinyapps.io dashboard under:")
    message("Account -> Tokens -> Show/New Token")
    
    # Prompt for credentials if not provided
    account_name <- readline("Enter your shinyapps.io account name: ")
    token <- readline("Enter your token: ")
    secret <- readline("Enter your secret: ")
  }
  
  # Validate input
  if (nchar(account_name) == 0 || nchar(token) == 0 || nchar(secret) == 0) {
    stop("All credentials must be provided")
  }
  
  # Set account info
  tryCatch({
    rsconnect::setAccountInfo(
      name = 'yangzhicheng',
      token = '2466E6D8F0A9825E6E47ADB05EF47415',
      secret = 'alVhfaH2fj3CdxemcdPUVG5onCTTyzfKdoGngaZz'
    )
    message("Successfully configured shinyapps.io account!")
    
  }, error = function(e) {
    message("Error configuring account: ", e$message)
    stop("Configuration failed")
  })
}

# If running this script directly, prompt for credentials
if (identical(environment(), globalenv())) {
  configure_shinyapps()
} 