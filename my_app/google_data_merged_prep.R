# Libraries --------------------------------------------------------------------

library(devtools)
library(tidyverse)
library(cartography)
library(sp)
library(leaflet)
library(maps)
library(plotly)
library(viridis)# virids package for the color palette
library(mapproj)
library(ggrepel)
library(ggiraph)
library(treemap)
#install_github("timelyportfolio/d3treeR")
#install.packages("remotes")
library(d3treeR)
library(shiny)
library(shinysurveys)
library(googlesheets4)
library(googledrive)

################################################################################

# 1. Download the company data from google sheet and read data -----------------

# Set the number of the column
n <- 34

# Get the ID of the sheet 
# This should be placed at the top of your shiny app
sheet_id <- googledrive::drive_get("questionaire_company")$id

# Read data from google sheet
questionnaire_company <- read_sheet(sheet_id)
questionnaire_company

# 2. Check if there is an update in the google sheet ---------------------------
if(nrow(questionnaire_company) < 2 ){
  # If there is no update then, set as empty data.frame
  data_update_company <- as.null(questionnaire_company)
}else{
  data_update <- questionnaire_company%>%
    # Check the duplicated data inside the google sheet
    distinct()%>%
    select(subject_id, question_id, response)%>%
    mutate(cols = rep(1:n, n()/n), id = rep(1:(n()/n), each = n))
  # Convert data to the base data format
  data_update <-  pivot_wider(data_update, id_cols = subject_id, names_from = question_id,
                              values_from = response, names_prefix = "")
  # Remove the subject id generated from the google sheet
  data_update <- data_update[,-1]
  # Rename the colname companyinput as Company
  colnames(data_update)[8] <- c("Company")
}
#Error in `mutate()`:
# Problem while computing `cols = rep(1:n, n()/n)`.
# Check the google sheet for duplicates



# Separate the data into two data set, one for company, one for the personal profile
# For company
# Select all the variables we need
data_update_company <- data_update %>%
                       select(Company,Type,Protein.Category,Brief.Description,
                              Location.Regions,Country,Technology.Focus,Contact.email,
                              Website,Logo,Company.Focus,Product.Type,Animal.Type.Analog,
                              Ingredient.Type, Operating.Regions,State,City,
                              Year.Founded,Founders,Parent.Company, Researcher.name,
                              Position,Host.Institution,Research.focus, Collaboration.opportunities)
# After merge with the company data (basic), still need to check the duplication

# For personal profile
 data_update_employee <- data_update %>%
                          select(Title,Employee.Name,Contact.Email,Linkedin.Profile,
                                 Educational.Details,Language,Type,Company,
                                 Location.Regions,Country,State,City,Website,
                                 Current.Position,Brief.Description,Founders,                   
                                 Parent.Company,Company.Focus,Technology.Focus,
                                 Product.Type,Animal.Type.Analog,Ingredient.Type,           
                                 Operating.Regions,Collaboration.opportunities,
                                 Previous.Company,Previous.Position)
#save the employee
 

# Delete all the rows from the google sheet online, so we have empty sheet for new data
# Company data
#range_delete(ss = sheet_id, sheet = "questionaire_company", range = "2:new" )

# Check duplicates and merge data_update_company with the template 
# and the basic data