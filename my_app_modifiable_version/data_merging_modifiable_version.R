
# 0. Libraries -----------------------------------------------------------------

library(devtools)
library(tidyverse)
library(leaflet)
library(maps)
library(plotly)
library(viridis)
library(mapproj)
library(ggrepel)
library(ggiraph)
library(treemap)
library(d3treeR)
library(shiny)

################################################################################

# 1.Read data ------------------------------------------------------------------

#DataCompany <- read.csv("~/InnoLab-Adea/datasets/raw_datasets/bright_data/LinkedIn company information datasets (Public web data).csv")
#DataPeople <- read.csv("~/InnoLab-Adea/datasets/raw_datasets/bright_data/LinkedIn people profiles datasets (Public web data).csv")
DataOriginalExcel <- read.csv("~/InnoLab-Adea/datasets/raw_datasets/GFI_manufacturers_and_brands.csv")
DataWV <- read.csv("~/InnoLab-Adea/datasets/raw_datasets/ingredients_and_equipment.csv")
DataEurope <- read.csv("~/InnoLab-Adea/datasets/raw_datasets/ingredients_and_suppliers_in_eu.csv")
DataEuropean <- read.csv("~/InnoLab-Adea/datasets/raw_datasets/european_researcher_directory.csv")
DataGFI <- read.csv("~/InnoLab-Adea/datasets/raw_datasets/GFI_careers_board.csv")
DataWebsite <- read.csv("~/InnoLab-Adea/datasets/raw_datasets/GFI_manufacturers_and_brands_with_investment_information.csv")

################################################################################

# 2. Merge datasets ------------------------------------------------------------
## we merge base on the original dataset

#### 2.1 merge the original dataset with DataWV --------------------------------

colnames(DataOriginalExcel)
colnames(DataWV)
data1 <- rbind(DataOriginalExcel, DataWV) # 1776obs

# delete duplicate
data1 <- unique(data1) # 1648obs

#### 2.2 merge data with DataWebsite -------------------------------------------

colnames(data1)

# renames columns to be the same as DataOriginal
colnames(DataWebsite) <- c("Company", "Brief.Description", "Protein.Category",
                           "Company.Focus", "Current.round", "Target.deal.size",
                           "Amount.raised.to.date.for.this.round", "Total.investment.to.date", 
                           "Asset.type", "Target.investor.types", "Pitch.deck..optional.",
                           "Video.of.pitch..optional.", "Technology.Focus", 
                           "Product.Type", "Animal.Type.Analog", "Ingredient.Type", 
                           "Operating.Regions", "Country.Region", "Founders", 
                           "Year.Founded", "Contact.email" , "Website")

# select relevant variables
DataWebsite <- DataWebsite %>% 
                select("Company", "Brief.Description", "Protein.Category", 
                       "Company.Focus", "Technology.Focus", "Product.Type", 
                       "Animal.Type.Analog", "Ingredient.Type", "Operating.Regions",
                       "Country.Region", "Founders", "Year.Founded", "Contact.email" , 
                       "Website")

# merge
data2 <- merge(data1, 
               DataWebsite,
               by = c( "Company", "Brief.Description", "Protein.Category", "Company.Focus", 
                       "Technology.Focus", "Product.Type", "Animal.Type.Analog",
                       "Ingredient.Type", "Operating.Regions", "Country.Region", 
                       "Founders", "Year.Founded", "Website"), 
               all=TRUE)

#### 2.3 merge data with DataEurope --------------------------------------------

colnames(DataEurope)
colnames(data2)

# drop "Primary.Focus.Alternative.Proteins." Variable
DataEurope <- DataEurope %>% 
              select(-Primary.Focus.Alternative.Proteins.)

# merge
# #data3 <- merge(data2, 
#                 DataEurope, 
#                 by = c( "Company", "Brief.Description", "Protein.Category", 
#                         "Company.Focus", "Technology.Focus", "Product.Type", 
#                         "Animal.Type.Analog", "Ingredient.Type", "Operating.Regions", 
#                         "Country.Region", "State", "City", "Website", "Year.Founded",
#                         "Founders", "Logo"),
#                 all=TRUE)
data3 <- merge(data2, 
               DataEurope, 
               by = intersect(colnames(DataEurope),colnames(data2)),
               all= TRUE)

#### 2.4 merge data with DataEuropean ------------------------------------------

colnames(data3)
colnames(DataEuropean)

# drop irrelevant variables
DataEuropean <- DataEuropean %>% 
                select(-c("Hiring.for", "Disciplines", "Active.status"))

# change the name of variables
colnames(DataEuropean) <- c("Company", "Researcher.name", "Position", "Host.Institution", 
                            "Country.Region", "Protein.Category", "Technology.Focus", 
                            "Research.focus", "Collaboration.opportunities", "Contact.email")

# add "Type" Variable to differentiate if it is a company or a lab
DataEuropean$Type <- "Research lab"
data3$Type <- "Company"

# merge
data4 <- merge(data3, 
               DataEuropean, 
               by = c("Company", "Type", "Country.Region", "Protein.Category", 
                      "Technology.Focus", "Contact.email"), 
               all=TRUE)
# data4 <- merge(data3,
#         DataEuropean,
#         by = intersect(DataEuropean, data3),
#         all=TRUE)

#### 2.5 merge data with DataGFI -----------------------------------------------

colnames(data4)
colnames(DataGFI)

# drop irrelevant variables
DataGFI <- DataGFI %>% 
           select(-c("Title", "Role.Type", "Link", "Application.Deadline"))

# change the name of variables
colnames(DataGFI) <- c("Company", "Type", "Protein.Category", "Brief.Description", 
                       "Location.Regions", "Country.Region")

# split the location.regions variable
DataGFI <- DataGFI %>%              
            mutate(Location.Regions=strsplit(Location.Regions, ",")) %>% 
            unnest(Location.Regions)

# replace "Asia - Pacific" with "Asia Pacific" 
DataGFI$Location.Regions[DataGFI$Location.Regions == "Asia - Pacific"] <- "Asia Pacific"

# replace "Africa" with "Africa/Middle East"
DataGFI$Location.Regions[DataGFI$Location.Regions == "Africa"] <- "Africa/Middle East"

# Group the countries into different regions
# change value names to make the name unique
for (i in 1:nrow(data4)){
  if (data4$Country.Region[i] == "Italia"){
    data4$Country.Region[i] <- "Italy"
  } else if (data4$Country.Region[i] == "Italy "){
    data4$Country.Region[i] <- "Italy"
  } else if (data4$Country.Region[i] == "España"){
    data4$Country.Region[i] <- "Spain"
  } else if (data4$Country.Region[i] == "UK"){
    data4$Country.Region[i] <- "United Kingdom"
  } else if (data4$Country.Region[i] == "Deutschland"){
    data4$Country.Region[i] <- "Germany"
  } else if (data4$Country.Region[i] == "Norge"){
    data4$Country.Region[i] <- "Norway"
  } else if (data4$Country.Region[i] == "Türkiye"){
    data4$Country.Region[i] <- "Turkey"
  } else if (data4$Country.Region[i] == "Mainland China"){
    data4$Country.Region[i] <- "China"
  } else if (data4$Country.Region[i] == "India "){
    data4$Country.Region[i] <- "India"
  } 
}

# Group "Asia Pacific"
region_AsiaPacific <- c("India", "Singapore","Japan", "South Korea", "China",
                        "Thailand","Philippines","Vietnam","Malaysia","Indonesia",
                        "Taiwan","Pakistan","Sri Lanka")

# Group "Europe"
region_europe <- c("United Kingdom","Spain","Sweden","France","Germany","Romania",
                   "Italy", "Belgium","Switzerland","Croatia","Greece","Russia",
                   "Slovenia", "Netherlands","Finland","Czech Republic","Denmark",
                   "Serbia", "Estonia","Bulgaria","Poland","Ireland","Norway",
                   "latvia", "Portugal","Cyprus","Ukraine", "Monaco","Iceland",
                   "Hungary", "Belarus", "Austria")

# Group North America: "U.S. and Canada" 
region_NorthAmerica <- c("United States", "Canada")

# Group "Latin America" and south america
region_LatinAmerica <- c("Brazil","Chile","Peru","Argentina","Mexico","Ecuador","Venezuela")

# Group "Africa/Middle East"
region_AfricaMiddleEast <- c("Israel","Turkey","South Africa","Ghana","Nigeria")

# Group "Australia/New Zealand"
region_AustraliaNZ <- c("New Zealand","Australia")

# set an new variable "Location.Regions"
data4$Location.Regions = NA

for (i in 1:nrow(data4)){
  if (data4$Country.Region[i] %in% region_AsiaPacific){
    data4$Location.Regions[i] <- "Asia Pacific"
  } else if (data4$Country.Region[i] %in% region_europe){
    data4$Location.Regions[i] <- "Europe"
  } else if (data4$Country.Region[i] %in% region_NorthAmerica){
    data4$Location.Regions[i] <- "North America"
  } else if (data4$Country.Region[i] %in% region_LatinAmerica){
    data4$Location.Regions[i] <- "Latin America"
  } else if (data4$Country.Region[i] %in% region_AfricaMiddleEast){
    data4$Location.Regions[i]<- "Africa/Middle East"
  } else if (data4$Country.Region[i] %in% region_AustraliaNZ){
    data4$Location.Regions[i] <- "Australia/New Zealand"
  }
}

# merge
colnames(data4)
colnames(DataGFI)
data <- merge(data4, 
              DataGFI, 
              by = c("Company", "Type", "Protein.Category", "Brief.Description", 
                     "Location.Regions", "Country.Region"), 
              all=TRUE)

################################################################################

# 3. Clean the data ------------------------------------------------------------
# fill NA Values as ""
colnames(data)
data<- data %>%  
       mutate_at(c("Year.Founded" ), ~replace_na(.,0))
data[is.na(data)] <- ""

# change value names to make the name unique
for (i in 1:nrow(data)){
    if (data$Country.Region[i] == "Berlin or remote in DE, ES, NL, PL, UK, CZ & ZA"){
    data$Country.Region[i] <- "Germany"
  } else if (data$Country.Region[i] == "Location: remote (home-based), CET time zone preferred, ideally in the UK, NL, GER, PL, CZ, or ES"){
    data$Country.Region[i] <- "Remote"
  } else if (data$Country.Region[i] == "Shanghai (preferred) or remotely in China/Taiwan"){
    data$Country.Region[i] <- "China"
  } else if (data$Country.Region[i] == "KS, United States"){
    data$Country.Region[i] <- "United States"
  }
}

# renames some variables
data <- data %>% 
        rename(Country = Country.Region)
