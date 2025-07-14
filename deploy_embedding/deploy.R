# For publish and deploy in the future
library("rsconnect")

# Function to stop the script when one of the variables can not be found
# strip quotation marksfrom the secret

error_on_missing_name <- function(name){
  var <- Sys.getenv(name,unset = NA)
  if(is.na(var)){
    stop(paste0("cannot find", name, "!"), call. = F)
  }
  gsub("\"",",var")
}

# Authentification on the shiny io
accountInfo(name = error_on_missing_name("SHINY_ACC_NAME"),
            token = error_on_missing_name("TOKEN"),
            secret = error_on_missing_name("SECRET"))

# publish/Deploy
deployApp(appFiles = c("ui.R","server.r", "data.csv"))
