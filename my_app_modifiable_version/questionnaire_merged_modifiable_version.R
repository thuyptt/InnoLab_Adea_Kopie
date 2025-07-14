
# Libraries ------------------------------------------------------------------

library(shinysurveys)
library(googlesheets4)
library(googledrive)
library(gargle)

# 1.Load the dataset------------------------------------------------------------
source(file = "~/InnoLab-Adea/my_app_modifiable_version/final_data_prep_modifiable_version.R")

# Google sheet authentification
#gs4_auth(cache = "~/InnoLab-Adea/my_app_modifiable_version/.secrets", email = T)

# Create a google sheet (use it only for once)
# main <-  googlesheets4::gs4_create(name = "questionnaire_company",
#          Create a sheet called main for all data to go to the same place
#                                       sheets = "questionaire_company")


# 3. Get the ID of the sheet ---------------------------------------------------
# This should be placed at the top of your shiny app
#sheet_id <- googledrive::drive_get("questionaire_company")$id

# 4. Add option checkbox -------------------------------------------------------
extendInputType("checkbox", 
                {shiny:: checkboxGroupInput(inputId = surveyID(),
                                                        label = surveyLabel(),
                                                        choices = surveyOptions())})

# 5. Define questions in the format of a shiny survey --------------------------
# + means mandantory questions
survey_questions_merged <- data.frame(
  question = c(
    # page1
    # Title
    "Title",
    # Employee.Name +
    c("Q1: What is your first and last name?"),
    # Contact.email+ 
    "Q2: Please provide us your contact e-mail.",
    # linkedin profile
    "Q3: Please provide us your Linkedin website.",
    # educational.details        multiple choices
    "Q4: Please provide your educational backgrounds. ",
    # language            
    "Q5: Which languages can you speak?",
    # page2
    # Type relate to TF and RF+
    c(rep("Q6: What type is the entity you´re working at?",time = 6)),
    # Company+
    "Q7: What is the name of the Company/Lab you are currently working for?",
    # Location.Regions
    # Which region is your company based in
    c(rep("Q8: Which region is your company/Lab based in.",time = 7)),
    # Country+
    c(rep("Q9:In which country are your headquarters?",time = 242)),
    # 10.State                       free input
    "Q10: In which state/province do you work?",
    # 11.City
    "Q11:Which city is your company/Lab based in?",
    # 12Website+
    "Q12: Please provide us your companies or insitutions website.",
    # 8.Contact.email
    "Q8: Please provide us your companies or insititutions contact e-mail.",
    # 13.Logo
    "Q13: Please provide us your companies or insititutions logo (only URL)",
    # page3
    #14.Position+
    "Q14: What is your current position?",
    #15. Brief.Description
    "Q15:Please give a short description of your company´s core activities and interest fields",
    # 16.Year.Founded            select limitations > 1970 < current year
    c(rep("Q16: In which year was your company founded?", time = 54)),
     #17. Founders                  free, separate with , name, last name
    "Q17: Who is the Founder(s) of  your company? (If there is more than one founders, use comma to seperate)",
    # 18.Parent.Company            
    "Q18: Does your company have a parent company?(If your company does not have a parent company, leave it empty)",
    # Industry+
    #c("Q8: Which industry are you currently working in?"),
    # page4
    # 19.Protein.Category+
    c(rep("Q19: What Protein Category would best fit your company´s focus? (Check all that apply)",time = 9)),
    # 20.Company.Focus+
    c(rep("Q20: What is your company focus? (Check all that apply)", time = 9)),
    # 21.Technology.Focus+
    c(rep("Q21: If you currently working in the Cultured Meat industry, can you provide us the Technology Focus of your company? (Check all that apply)",time = 10)),
    # Product.Type+             multiple choices
    c(rep("Q22: What is your product type? (Check all that apply)", time = 13)),
    # Animal.Type.Analog +        multiple choices
    c(rep("Q23: Which animal type analog do you use? (Check all that apply) ", time = 14)),
    # Ingredient.Type             multiple choices
    c(rep("Q24: Which ingredient are you specialized in? (Check all that apply)", time = 10)),
    # Operating.Regions+ 
    c(rep("Q25: Which of the followings are your operating region? (Check all that apply)", time = 7)),
    # page5
    # Collaboration.opportunities
    "Q26: are you looking for any collaboration opportunities? (exp. Joint research,Industry partnership) ",
    # Previous.company
    c("Q27: Have you worked for other cultured meat related companies before? Please list the name of the companies ( If there are more companies, please use comma to seperate)"),
    # Previous.position               multiple choices
    c("Q28: What are your positions in the previous companies? Please list the names of the positions ( If there are more companies, please use comma to seperate)"),
    # Researcher.name            if lab = truethen free input
    c("Q29: If you choose the Research Lab in the Q3, 
      we recommend you to answer following questions.           What is name of Rearchers? (If there is more than one researchers, use comma to seperate"),
     # 22.Position 2
    "Q30: What is the postiton of the Researcher?",
    # 23.Host.Institution"
    "Q31: What is the Host Institution of the Research Lab?",
    # 24.Research.focus 
    "Q32: What is the Research Focus of the Research Lab?"
  ),
  option = c(
    #Title 
    "",
    # Employee.Name
    "",
    # Contact.Email
    "",
    # linkedin profile
    "",
    # educational.details
    "",
    # language 
    "",
    # Type
    c("Company","Research lab","For-Profit: Startup","For-Profit: Industry",                         
      "For-Profit: Incubator / Accelerator",
      "Non-Profit" ),
    # Company+
    "",
    # Location.Regions 7
    c("Latin America", "North America","Asia Pacific", "Europe",
      "Africa/Middle East","Australia/New Zealand", "Other"),
    # Country 242
    unique(data_world$Country),
    # state
    "",
    # city
    "",
    # Website
    "",
    # 8.Contact.email
    "",
    # Logo
    "",
    # position
    "",
    # Brief.Description
    "",
    # Year.Founded
    c(1970:as.integer(format(Sys.Date(), "%Y"))),
    # Founders
    "",
    # Parent.Company 
    "",
    # Protein.Category 9
    c("Plant_based","Biomass Fermentation","Cultivated","Cultivated meat",
      "Fermentation-derived","Fermentation","Traditional Fermentation","Precision Fermentation",
      "Plant molecular Farming"),
    # Company.Focus 9
    c("Seafood","Meat","Ingredients and inputs","Other",
      "Eggs","Food processing infrastructure and equipment",
      "Contract manufacturing/processing","Dairy",
      "Bioprocessing infrastructure and equipment"),
    # Technology Focus 10
    c("End product formulation and manufacturing",
      "Ingredient optimization","Crop development",
      "Cell culture media","Bioprocess design",
      "Cell line development","Scaffolding and structure",
      "Target molecule selection",
      "Host strain development",
      "Feed stocks"),
    # Product.Type 13
    c("Ground meat", "Whole muscle meat",
      "Other meat","Milk","Other","Eggs","Cheese","Other dairy",
      "Pet food","Ingredients","Oils and fats","Seafood",
      "Infant nutrition"),
    # Animal.Type.Analog 14
    c("Beef/veal","Fish","Duck","Chicken",
      "Shellfish","Pork","Other","Turkey","Tuna","Mutton/lamb",
      "Crab","Antelope","Goat","No specialization"),
    # Ingredient.Type 10
    c("Soy","Pea","Palm",
      "Seaweed","Almond",
      "Cashew","Other",
      "Rice","Algae","No specialization"),
    # Operating.Regions 7
    c("Latin America", "North America","Asia Pacific", "Europe",
      "Africa/Middle East","Australia/New Zealand", "Global"),
    # Collaboration.opportunities
    "",
    # Previous.Company
    "",
    # Previous.Position
    "",
    # Researcher.name                      
    "",
    # 22.Position 2
    "",
    # 23.Host.Institution"
    "",
    # 24.Research.focus 
    ""),
    
  
  input_type = c(# Title
    "text",
    # Employee.Name
    "text",
    # Contact.Email+ 
    "text",
    # Linkedin.Profile
    "text",
    # Educational.Details
    "text",
    # Language
    "text",
    # Type
    c(rep("select",time = 6)),
    # Company
    "text",
    # Regions
    c(rep("select",time = 7)),
    # Country
    c(rep("select", time = 242)),
    # State
    "text",
    # City
    "text",
    # Website
    "text",
    # Contact.email
    "text",
    # Logo
    "text",
    # Current.Position"
    "text",
    # Breif.Description
    "text",
    # Year.Founded
    c(rep("select",time = 54)),
    # Founders       
    "text",
    # Parent.Company  
    "text",
    # Protein.Category 9
    c(rep("checkbox", time = 9)),
    # Company.Focus
    c(rep("checkbox", time = 9)),
    # Technology.Focus
    c(rep("checkbox", time = 10)),
    # Product.Type 
    c(rep("checkbox", time = 13)),
    # Animal.Type.Analog 
    c(rep("checkbox", time = 14)), 
    # Ingredient.Type
    c(rep("checkbox", time = 10)),
    # Operating.Regions
    c(rep("checkbox", time = 7)),
    # Collaboration.opportunities
    "text",
    # Previous.Company
    "text",
    # Previous.Position
    "text",
    # Researcher.name                      
    "text",
    # 22.Position 2
    "text",
    # 23.Host.Institution"
    "text",
    # 24.Research.focus 
    "text"
    ),
  
  input_id = c("Title",
               "Employee.Name", 
               "Contact.Email",
               "Linkedin.Profile",
               "Educational.Details",
               "Language",
               c(rep("Type",time = 6)),
               "companyinput",
               c(rep("Location.Regions ",time = 7)),
               c(rep("Country", time = 242)),
               "State",
               "City",
               "Website",
               "Contact.email",
               "Logo",
               "Current.Position",
               "Brief.Description",
               c(rep("Year.Founded",time = 54)),
               "Founders",
               "Parent.Company",
               c(rep("Protein.Category", time = 9)),
               c(rep("Company.Focus", time = 9)),
               c(rep("Technology.Focus", time = 10)),
               c(rep("Product.Type", time = 13)),
               c(rep("Animal.Type.Analog", time = 14)), 
               c(rep("Ingredient.Type", time = 10)), 
               c(rep("Operating.Regions", time = 7)),
               "Collaboration.opportunities",
               "Previous.Company",
               "Previous.Position",
               "Researcher.name","Position","Host.Institution","Research.focus"),
  
  dependence = c(rep(NA, time = 404)),
  
  dependence_value = c(rep(NA, time = 404)),
  # set mandantory questions
  required = c(F, 
               # Employee.Name +
               T,
               # Contact.Email+ 
               T,
               # linkedin profile
               F,
               # Educational.details   
               F,
               # Language
               F,
               # page2
               # Type
               c(rep(T,time = 6)),
               # companyinput
               T,
               # Location.Regions
               c(rep(T,time = 7)),
               # Country
               c(rep(T,time = 242)),
               # State  
               F,
               # City
               F,
               # Website
               T,
               # Contact.email
               T,
               # Logo
               F,
               # page3
               # Current.Position
               T,
               # Breif.Description
               F,
               # Year.Founded
               c(rep(F, time = 54)),
               # Founders
               F,
               # Parent.Company
               F,
               # page4
               # Protein.Category
               c(rep(T, time = 9)),
               # Company.Focus
               c(rep(T, time = 9)),
               # Technology.Focus 
               c(rep(T, time = 10)),
               # Product.Type
               c(rep(T, time = 13)),
               # Animal.Type.Analog
               c(rep(T, time = 14)),
               # Ingredient.Type
               c(rep(F, time = 10)), 
               # Operating.Regions
               c(rep(T, time = 7)),
               # page5
               # Collaboration.opportunities
               F,
               # Previous.Company
               F,
               # Previous.Position
               F,
               #Researcher.name
               F,
               # Position
               F, 
               # Host.Institution
               F,
               # Research.focus
               F))


# multipage
# multiQuestions <- survey_questions_merged %>%
#                    mutate(page = c(rep(1, 6), rep(7, 267), rep(268, 272), 
#                                    rep(273,344), rep(345,351)))

