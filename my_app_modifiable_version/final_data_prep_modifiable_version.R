
# Libraries -----------------------------------------------------------------

library(devtools)
library(dplyr)
library(tidyverse)
library(cartography)
library(sp)
library(leaflet) # create world map
library(maps)
library(plotly)
library(viridis)# virids package for the color palette
library(mapproj)
library(ggrepel)
library(ggiraph)
library(treemap) # create value chain
#install_github("timelyportfolio/d3treeR")
library(d3treeR) # make the treemap interactive
library(shiny) # create shiny app
library(readxl)
library(naniar)

################################################################################

# 1. Load the final data -------------------------------------------------------

data_final <- read.csv(file="~/InnoLab-Adea/datasets/final_datasets/data.csv")
# To add the new data later, please firstly add the data to the template dataset
# then combine the template data set with the loaded above final data

#source(file = "~/InnoLab-Adea/my_app_modifiable_version/google_data_merged_prep_modifiable_version.R")
data_com_new <- read_excel("~/InnoLab-Adea/datasets/final_datasets/template_for_company_dataset.xlsx", sheet="Template company dataset")
data_emp_new <- read_excel("~/InnoLab-Adea/datasets/final_datasets/template_for_employee_dataset.xlsx", sheet="Template employee dataset")
data <- rbind(data_final, data_emp_new, data_com_new) #data_update_company

# Remove duplication
data <- unique(data)

################################################################################

# 2. Define specific region group ----------------------------------------------

## Group "Asia Pacific"
region_AsiaPacific <- c("India", "Singapore","Japan", "South Korea", "China",
                        "Thailand","Philippines","Vietnam","Malaysia","Indonesia",
                        "Taiwan","Pakistan","Sri Lanka")

## Group "Europe"
region_europe <- c("United Kingdom","Spain","Sweden","France","Germany","Romania",
                   "Italy", "Belgium","Switzerland","Croatia","Greece","Russia",
                   "Slovenia", "Netherlands","Finland","Czech Republic","Denmark",
                   "Serbia","Estonia","Bulgaria","Poland","Ireland","Norway","latvia",
                   "Portugal","Cyprus","Ukraine", "Monaco","Iceland","Hungary",
                   "Belarus", "Austria")

## Group North America: "U.S. and Canada" 
region_NorthAmerica <- c("United States", "Canada")

## Group "Latin America" and south america
region_LatinAmerica <- c("Brazil","Chile","Peru","Argentina","Mexico","Ecuador","Venezuela")

## Group "Africa/Middle East"
region_AfricaMiddleEast <- c("Israel","Turkey","South Africa","Ghana","Nigeria")

## Group "Australia/New Zealand"
region_AustraliaNZ <- c("New Zealand","Australia")

################################################################################

# 3- Explore the dataset -------------------------------------------------------

#### 3.1 Get an overview of the dataset ----------------------------------------

summary(data)
str(data)

#### 3.2 Filter only CM companies ----------------------------------------------

# Split the "Protein Category" variable to filter only CM companies
data_PC <- data %>%              
            mutate(Protein.Category=strsplit(Protein.Category, ",")) %>% 
            unnest(Protein.Category)

# Change name of the value in Protein Category to make it unite
for (i in 1:nrow(data_PC)) {
  if (data_PC$Protein.Category[i] == "Cultivated meat"){
    data_PC$Protein.Category[i] <- "Cultivated"
  } else if (data_PC$Protein.Category[i] == "Plant-Based"){
    data_PC$Protein.Category[i] <- "Plant-based"
  }
}

# Filter only cultivated meat companies
data_CM <- data_PC %>% 
            filter(Protein.Category %in% c("Cultivated"))

# Filter missing values in "Location.Regions" based on location Country
for (i in 1:nrow(data_CM)){
  if (data_CM$Country[i] %in% region_AsiaPacific){
    data_CM$Location.Regions[i] <- "Asia Pacific"
  } else if (data_CM$Country[i] %in% region_europe){
    data_CM$Location.Regions[i] <- "Europe"
  } else if (data_CM$Country[i] %in% region_NorthAmerica){
    data_CM$Location.Regions[i] <- "North America"
  } else if (data_CM$Country[i] %in% region_LatinAmerica){
    data_CM$Location.Regions[i] <- "Latin America"
  } else if (data_CM$Country[i] %in% region_AfricaMiddleEast){
    data_CM$Location.Regions[i]<- "Africa/Middle East"
  } else if (data_CM$Country[i] %in% region_AustraliaNZ){
    data_CM$Location.Regions[i] <- "Australia/New Zealand"
  }
}

# Remove duplications in the dataset
for(i in 1:(nrow(data_CM)-1)){
  if((data_CM$Company[i] == data_CM$Company[i+1]) && 
     (data_CM$Technology.Focus[i] == data_CM$Technology.Focus[i+1])) {
  data_CM[i+1,] <- data_CM[i,]
  }
}

data_CM <- unique(data_CM)

#### 3.3 Filter only the CM company which founded starting from 2011 -----------

# NOTE: There are 40 NA values in "Year.Founded"
data_CM_2011 <- data_CM %>% filter(Year.Founded > 2010)
summary(as.factor(data_CM$Year.Founded))

# Calculate the numbers of new CM company starting from 2011
count_Year.Founded <- data_CM_2011 %>% 
  count(Year.Founded) 

# Create new column in data set that contains cumulative count to calculate the total CM companies per Year.Founded
count_Year.Founded$n2 <- count_Year.Founded$n
count_Year.Founded$n2[[1]] <- count_Year.Founded$n2[[1]] + (nrow(data_CM) - nrow(data_CM_2011))
count_Year.Founded$cum_n <- cumsum(count_Year.Founded$n2)
### --> the CM companies which founded before 2011 + new CM companies = total CM companies

# Change cum_n column from int to num type
count_Year.Founded$cum_n <- as.numeric(count_Year.Founded$cum_n)

# Change type of Year.Founded from int to factor
count_Year.Founded$Year.Founded <- factor(count_Year.Founded$Year.Founded,
                                          levels = c("2011", "2012", "2013", 
                                                    "2014", "2015", "2016",
                                                    "2017", "2018", "2019", 
                                                    "2020", "2021", "2022"))
# Drop n2 column and change columns name
count_Year.Founded <- count_Year.Founded[c(1,2,4)]
colnames(count_Year.Founded) <- c("Year.Founded", "new", "total")    

# Save data for the visualization
# write.csv(data, file = "data.csv")
# write.csv(data_PC, file = "data_PC.csv")
# write.csv(data_CM, file = "data_CM.csv")

################################################################################

# 4. Data for the visualization ------------------------------------------------

#### 4.1 Exploratory Statistics ------------------------------------------------

## Figure 1-3: New and Total number of cultivated meat companies, by year founded ####

## Figure 4: Total cultivated meat companies by Protein Category ####
data_PC_count<- data_PC %>% count(Protein.Category)
data_PC_count

#### 4.2:  CM Company by Region/Country ----------------------------------------

## Figure 5: Total cultivated meat companies by Location.Regions ####
# Split the Location.Regions variable
data_CM_LR <- data_CM %>%              
              mutate(Location.Regions=strsplit(Location.Regions, ",")) %>% 
              unnest(Location.Regions)

# Number of CM Companies per Location.Regions
data_CM_LR_count <- data_CM_LR %>% count(Location.Regions)
data_CM_LR_count

## Figure 6: Total cultivated meat companies by Country ####
# Distribution of companies by country
NumberofCMInEachCountry <- data_CM %>% count(Country) 

#### Figure 7: Total cultivated meat companies by Company Focus ####
# Split the Company Focus variable
data_CM_CF <- data_CM %>%              
              mutate(Company.Focus=strsplit(Company.Focus, ",")) %>% 
              unnest(Company.Focus)

# Number of CM Companies per Company Focus
data_CM_CF_count <- data_CM_CF %>% count(Company.Focus)
data_CM_CF_count


#### Figure 8: Total cultivated meat companies by Product Type ####
data_CM_PT <- data_CM %>%              
              mutate(Product.Type=strsplit(Product.Type, ",")) %>% 
              unnest(Product.Type)

# Number of CM Companies per Product Type
data_CM_PT_count <- data_CM_PT %>% count(Product.Type)
data_CM_PT_count


#### Figure 9: Total cultivated meat companies by Operating Region ####
# Split Operating.Regions variable
data_CM_OR <- data_CM %>%              
              mutate(Operating.Regions=strsplit(Operating.Regions, ",")) %>% 
              unnest(Operating.Regions)

# Drop NA values
data_CM_OR <- data_CM_OR %>%
              replace_with_na(replace = list(Operating.Regions = c("N/A")))
data_CM_OR <- data_CM_OR %>% drop_na()

# Change value names to make the name unique
for (i in 1:nrow(data_CM_OR)){
  if (data_CM_OR$Operating.Regions[i] == "Africa"){
    data_CM_OR$Operating.Regions[i] <- "Africa/Middle East"
  } else if (data_CM_OR$Operating.Regions[i] == "Asia - Pacific"){
    data_CM_OR$Operating.Regions[i] <- "Asia Pacific"
  } else if (data_CM_OR$Operating.Regions[i] == "U.S. and Canada"){
    data_CM_OR$Operating.Regions[i] <- "North America"
  }
}
# Total cultivated meat companies by region
NumberofCMperRegion <- data_CM_OR %>% count(Operating.Regions)
NumberofCMperRegion

# New cultivated meat companies by region in 2021, 2022
NumberofNEWCMperRegion <- data_CM_OR %>% 
                          filter(Year.Founded > 2020) %>% 
                          count(Operating.Regions) 
colnames(NumberofNEWCMperRegion) <- c("Operating.Regions","new") 

# Adding column, which shows number of new CM companies in NumberofCMperRegion dataframe
NumberofCMperRegion <- NumberofCMperRegion %>% mutate(new=NumberofNEWCMperRegion$new)

# Adding existing Cm companies column
NumberofCMperRegion <- NumberofCMperRegion %>% mutate(existing=0)

for (i in 1:nrow(NumberofCMperRegion)) {
  NumberofCMperRegion$existing[i] = NumberofCMperRegion$n[i] - NumberofCMperRegion$new[i]
}

## Figure 10: Total cultivated meat companies by Technology Focus ####
# Split the value chain variable  
data_CM_VC <- data_CM %>%              
              mutate(Technology.Focus=strsplit(Technology.Focus, ",")) %>% 
              unnest(Technology.Focus)

data_CM_VC$Technology.Focus_grouped <- ""
  
for (i in 1:nrow(data_CM_VC)){
  if(data_CM_VC$Technology.Focus[i] %in% c("Cell lines","Cell line development", "Feedstocks", "Host strain development", "Crop development")){
    data_CM_VC$Technology.Focus_grouped[i] <- "Cell Line Development"
  } else if(data_CM_VC$Technology.Focus[i] %in% c("Cell culture media", "Ingredient optimization", "Target molecule selection")){
    data_CM_VC$Technology.Focus_grouped[i] <- "Cell Culture Media and Ingredients"
  } else if(data_CM_VC$Technology.Focus[i] %in% c("Bioprocess design")){
    data_CM_VC$Technology.Focus_grouped[i] <- "Bioreactors/Cell Cultivation Systems"
  } else if(data_CM_VC$Technology.Focus[i] %in% c("Scaffolding and structure", "3D printing")){
    data_CM_VC$Technology.Focus_grouped[i] <- "Scaffolding"
  } else if(data_CM_VC$Technology.Focus[i] %in% c("End product formulation and manufacturing")){
    data_CM_VC$Technology.Focus_grouped[i] <- "End product formulation & manufacturing"
  } else {
    data_CM_VC$Technology.Focus_grouped[i] <- data_CM_VC$Technology.Focus[i]
  }
}

# Number of CM Companies per value chain
data_CM_VC_count <- data_CM_VC %>% count(Technology.Focus)
data_CM_VC_count

#### Figure 11: Total cultivated meat companies by Animal Type Analog ####
# Split the Animal.Type.Analog variable
data_CM_ATA <- data_CM %>%
                mutate(Animal.Type.Analog=strsplit(Animal.Type.Analog, ",")) %>%
                unnest(Animal.Type.Analog)
# Number of CM Companies per Animal Type Analog
data_CM_ATA_count <- data_CM_ATA %>% count(Animal.Type.Analog)

#### Figure 12: Total cultivated meat companies by Location Regions ####
# Make a list of data frames then use lapply to apply the function to them all
plot_list <- list(NumberofCMInEachCountry, NumberofCMperRegion,
                  data_CM_VC_count, data_PC_count, data_CM_CF_count,
                  data_CM_PT_count, data_CM_ATA_count, data_CM_LR_count)

#### Figure 13: World map ####
# Get the world polygon and extract DE
world <- map_data("world")

# Get a data frame with longitude, latitude, and size of bubbles (a bubble = a city)
data_world <- world.cities 
data_world <- data_world %>% select(country.etc, lat, long)
head(data_world)

data_world <- data_world %>% 
              group_by(country.etc) %>%
              summarise(lat = mean(lat, na.rm = TRUE), long = mean(long, na.rm = TRUE))

# Rename the columns
colnames(data_world) <- c("Country", "lat", "long")

# Adding Scotland to the data_world
scotland <- data.frame(Country = "Scotland",
                       lat = 55.953251,
                       long = -3.188267)
sapply(scotland, class)
data_world <- rbind(data_world, scotland)
sapply(data_world, class)

# Change the name of USA, UK, South Korea, and Norway so that 
# the names are the same in these two datasets
for (i in 1:nrow(data_world)){
  if (data_world$Country[i] == "USA"){
    data_world$Country[i] = "United States"
  } else if (data_world$Country[i] == "UK"){
    data_world$Country[i] = "United Kingdom"
  } else if (data_world$Country[i] == "Korea South"){
    data_world$Country[i] = "South Korea"
  }
}

# Merge
data_CM_merged <- merge(data_CM, data_world, by="Country")

# Value chain
data_CM_merged_VC <- data_CM_merged %>%              
                      mutate(Technology.Focus = strsplit(Technology.Focus, ",")) %>% 
                      unnest(Technology.Focus)


for (i in 1:nrow(data_CM_merged_VC)){
  if(data_CM_merged_VC$Technology.Focus[i] %in% c("Cell lines","Cell line development")){
    data_CM_merged_VC$Technology.Focus[i] <- "Cell Line Development"
  } else if(data_CM_merged_VC$Technology.Focus[i] %in% c("Cell culture media", "Ingredient optimization", "Target molecule selection")){
    data_CM_merged_VC$Technology.Focus[i] <- "Cell Culture Media and Ingredients"
  } else if(data_CM_merged_VC$Technology.Focus[i] %in% c("Bioprocess design")){
    data_CM_merged_VC$Technology.Focus[i] <- "Bioreactors/Cell Cultivation Systems"
  } else if(data_CM_merged_VC$Technology.Focus[i] %in% c("Scaffolding and structure", "3D printing")){
    data_CM_merged_VC$Technology.Focus[i] <- "Scaffolding"
  } else if(data_CM_merged_VC$Technology.Focus[i] %in% c("End product formulation and manufacturing")){
    data_CM_merged_VC$Technology.Focus[i] <- "End product formulation & manufacturing"
  }
}

# The company in scotland does not have Technology Focus
# add ist seperately
company_scot <- data_CM_merged %>% filter(Country == "Scotland") 
data_CM_merged_VC <- rbind(company_scot, data_CM_merged_VC)

# Create one dataset for the World map for 
# the number of Cm company per Country per TF
data_CM_VC_count_map <- as.data.frame(data_CM_merged_VC %>%  
                                        group_by(Country, Technology.Focus) %>% 
                                        count(Technology.Focus))
unique(data_CM_VC_count_map$Country)

# Data for the worldmap
# Reorder data + Add a new column with tooltip text
NumberofCMInEachCountry <- data_CM_merged %>% count(Country, long, lat, sort = TRUE) 
NumberofCMInEachCountry

NumberofCMInEachCountry <- NumberofCMInEachCountry %>%
  arrange(n) %>%
  mutate(country=factor(Country, unique(Country))) %>%
  mutate(mytext=paste("Country: ", Country, "\n", 
                      "Number of CM companies: ", n, sep=""))

# Change long and lat character to numeric
sapply(scotland, class)
sapply(data_world, class) 
sapply(NumberofCMInEachCountry, class)

# Below show the table data_CM_merged for thr further info

#### Figure 14: Value chain with treemap ####
df1 <- data_CM_VC %>% 
        group_by(Technology.Focus_grouped, Technology.Focus, Company, Brief.Description, 
                 Website, Founders, Year.Founded, Location.Regions, Country, 
                 Operating.Regions, Company.Focus, Product.Type, Animal.Type.Analog,
                 Research.focus, Contact.email, Researcher.name, Position, 
                 Host.Institution, Collaboration.opportunities) %>% 
        summarise(n = n())

# Delete the duplicate
df1 <- df1 %>% distinct()

# Create information column
df1$Information <- sprintf("Website: % s", as.character(df1$Website))

