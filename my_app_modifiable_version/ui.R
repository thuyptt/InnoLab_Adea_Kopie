
# Libraries ------------------------------------------------------------------

library(DT)
library(shinythemes)
library(shiny)
library(shinyWidgets)
library(shinydashboard)
library(collapsibleTree)
library(shinycssloaders)
library(tigris)
library(rintrojs)
library(htmltools)
# remotes::install_github("deepanshu88/summaryBox")
library(summaryBox)
#remotes::install_github("etiennebacher/shinyfullscreen")
library(shinyfullscreen)

# 1. Load the dataset with CM company and all alternative protein companies ----

source(file = "~/InnoLab-Adea/my_app_modifiable_version/final_data_prep_modifiable_version.R")
source(file = "~/InnoLab-Adea/my_app_modifiable_version/questionnaire_merged_modifiable_version.R")

# 2. Define Shiny UI ----------------------------------------------------------

shinyUI(fluidPage(
  navbarPage(title = div(img(src="adea_logo.svg", height='40', width='90', style="margin: -10px -10px; position : relative; display right-align;")), 
              tags$head(tags$style(HTML(".navbar-nav>li:nth-child(9) {float: right; right: -750px;}"))),  # contact-tab on right side
              id = "panels",   # for setting internal hyperlinks
              includeCSS("www/style/style_new.css"),
                  
              # tab panel 1 - Home ---------------------------------------------
              
              tabPanel("Home",
                       #icon = tags$img(src="https://cdn-icons-png.flaticon.com/128/263/263115.png", height='30', width='30', style="margin-bottom: 20px;"), 
                       
                       fluidRow(box(width=6, 
                                    title=h3("Find insights about the Cultured Meat Industry", style = 'font-size:42px;color:black;'),
                                    br(),
                                    span("Get a full overview about players in the market, the value chain and exploratory statistics about the newly evolving Cultured Meat market!", style = 'font-size:16px;'), 
                                    br(),
                                    br(),
                                    actionButton("link_Home_to_Stat", "Get started", class = "btn-lg",
                                                 style="color: #fff; background-color: #823F54; border-color: #823F54",
                                                 width = "200px")),
                                box(width = 6, img(src='steak.jpg', height='300', width='500', align = "right"))),
                       fluidRow(box(height="100px")),
                       
                       fluidRow(summaryBox2(width=4, icon="fas fa-users", "Cultured Meat Experts", "10+", style="winterwheat"),
                                summaryBox2(width=4, icon="fas fa-location-dot", "Countries", "30+", style="winterwheat"),
                                summaryBox2(width=4, icon="fas fa-building", "Cultured Meat Companies", "180+", style="winterwheat")),
                       fluidRow(box(height="100px")),
                       
                       fluidRow(box(width=2),
                                box(width=5, img(src='meat.png', height='400', width='400', align = "left")),
                                box(width=5, 
                                    title=h3("We Provide Many", span(strong("Features"), style="color: #823F54"),  "You Can Use", style = 'font-size:42px;color:black;'), 
                                    br(),
                                    span("You can explore the cultured meat industy by scrolling through our interactive and easy-to-use overview.", style = 'font-size:16px;'),
                                    br(),
                                    p(span(icon("circle-check"), "Explore all companies in the value chain"), style = 'font-size:16px;'),
                                    p(span(icon("circle-check"),"Find your worldwide competitors and suppliers"), style = 'font-size:16px;'),
                                    p(span(icon("circle-check"),"Interactive Statistics"), style = 'font-size:16px;'),
                                    p(span(icon("circle-check"),"Understand more about Cultured Meat"), style = 'font-size:16px;'))),
                       fluidRow(box(height="100px"))
                       ),
         
              # tab panel 2 - Statistics ----------------------------------
                
              tabPanel("Statistics",
                       span("This section provides you an overview of the cultured meat market.", style = 'font-size:16px;'),
                       br(),
                       br(),
                       hr(style="border-color: #823F54;"),
                       
                       tabsetPanel(tabPanel("Distribution of cultured meat companies over time",
                                             # Sidebar layout with input and output definitions 
                                            sidebarLayout(#Sidebar panel for inputs 
                                                          sidebarPanel(# Select variable for y-axis
                                                                      selectInput(inputId = "y",
                                                                                  label = "Select y-axis for the first figure:",
                                                                                  choices = c("Number of new cultured meat companies" = "new",
                                                                                              "Total number of cultured meat companies" = "total"),
                                                                                  selected = "new")
                                                                      ), 
                                                           # Output:  
                                                           mainPanel(# ggplot2 species charts section
                                                                     plotOutput("barplot1") %>% withSpinner(color = "green"),
                                                                     br(),
                                                                     br(),
                                                                     plotOutput("barplot2") %>% withSpinner(color = "green"),
                                                                     fullscreen_those(items = list("barplot1", "barplot2"))) 
                                                          )
                                            ), 
                       
                                   tabPanel("Distribution of cultured meat companies by selected variables",
                                            # Sidebar layout with input and output definitions 
                                            sidebarLayout(# Sidebar panel for inputs 
                                                          sidebarPanel(# Select variable for x-axis
                                                                       selectInput(inputId = "x",
                                                                                   label = "Select variable for the third figure:",
                                                                                   choices = c("Country" = "Country",
                                                                                               "Operating Regions" = "Operating.Regions",
                                                                                               "Technology Focus" = "Technology.Focus",
                                                                                               "Protein Category" = "Protein.Category",
                                                                                               "Company Focus" = "Company.Focus",
                                                                                               "Product Type" = "Product.Type",
                                                                                               "Animal Type Analog" = "Animal.Type.Analog",
                                                                                               "Location Regions" = "Location.Regions"),
                                                                                   selected = "Country"),
                                                                       ), 
                                                           # Output:  
                                                           mainPanel(plotOutput("barplot3", height = 800) %>% fullscreen_this() %>% withSpinner(color = "green" )
                                                                      )
                                                          )
                                            ) 
                                   )
              ), 

              # tab panel 3 - Worldmap ----------------------------------
              
              tabPanel("Worldmap",
                       span("You are interested in the cultured meat and wanna see how many cultivated meat companies are there in each country?
                            Use the map to search for your answer. Click on any one of them to get more detailed information.", style = 'font-size:16px;'),
                       br(),
                       br(),
                       span(strong("Tutorial: "), "Click and drag to zoom in, double click to zoom out. Please click on a bubble in the worldmap to get more insights in the table below", style = 'font-size:16px;'),
                       br(),
                       br(),
                       actionButton("link_WM_to_VC", ">> Go to Value chain", style="float:right; color: #fff; background-color: #823F54; border-color: #823F54"),
                       br(),
                       br(),
                       hr(style="border-color: #823F54;"),

                       h1("Distribution of the global players in the cultured meat market"),
                       mainPanel(plotlyOutput("mapplot", width = "150%",height = "700px") %>% withSpinner(color = "green"),
                                 tags$h2("Company lists of selected country"),

                                 dataTableOutput("maptable", width = "150%",height = "600px") %>% withSpinner(color = "green")
                                )
                      ),
             
              
              # tab panel 4 - Value chain --------------------------------------
             
              tabPanel("Value Chain",
                       span("In this section you can have a look at what companies and how many cultured meat companies are there in each step of the value chain.", style = 'font-size:16px;'),
                       br(),
                       br(),
                       fluidRow(box(width=12, img(src='valueChain.png', height='120', width='900'), align="center")),
                       br(),
                       br(),
                       span(strong("Tutorial: "), "In order to start the interactive plot
                         please select at least one region and one country.
                         When the plot pops up you can click on a square to get
                         to the next level of the plot. Continue this activity
                         until you reach the last level of this plot to see 
                         the related companies. In order to get back to the 
                         previous level please click on the bar title.", style = 'font-size:16px;'),
                       br(),
                       br(),
                       actionButton("link_VC_to_CI", ">> Go to Company information", style="float:right; color: #fff; background-color: #823F54; border-color: #823F54"),
                       actionButton("link_VC_to_WM", "<< Go back to Wordmap", style="float:left; color: #fff; background-color: #823F54; border-color: #823F54"),
                       br(),
                       br(),
                       hr(style="border-color: #823F54;"),
                       
                       sidebarLayout(sidebarPanel(fluidRow(column(12,
                                                                  selectInput("regionselect",
                                                                              label = "Select regions:",
                                                                              choices = c("North America","Europe","Africa/Middle East","Asia Pacific","Latin America","Australia/New Zealand",""), 
                                                                              selected = "North America",multiple = T)
                                                                  ),
                                                           column(12,
                                                                  selectInput("countryselect",
                                                                              label = "Select countries:",
                                                                              choices = c("Argentina","Australia", "Austria", "Belgium",
                                                                                           "Brazil", "Canada", "Chile", "China",
                                                                                           "Croatia","Czech Republic","Denmark","Estonia",
                                                                                           "France","Germany","Iceland","India",
                                                                                           "Ireland","Israel","Italy","Japan",
                                                                                           "Mexico","Netherlands","New Zealand","Norway",
                                                                                           "Poland","Portugal","Russia","Scotland",
                                                                                           "Singapore","South Africa","South Korea","Spain",
                                                                                           "Switzerland","Turkey","United Kingdom","United States"),
                                                                              selected = "United States",
                                                                              multiple = T)
                                                                  ),
                                                           column(12,
                                                                  span("Remark: To reselect a choice please click on the delete button on your keyboard")),
                                                           column(12,
                                                                  tableOutput('vcdis_countrytable')%>% withSpinner(color = "green"))
                                                           )
                                                  ),
                                     mainPanel(fluidRow(column(6,
                                                               actionButton("plot_full", "Show plot in fullscreen", style="float:left; color: #fff; background-color: #823F54; border-color: #823F54"),
                                                               br(), br(),
                                                               uiOutput("valuechain_countplot") %>% fullscreen_this(click_id = "plot_full") %>% withSpinner(color = "green") 
                                                               ) 

                                                        )
                                               )           
                                   )
                      ),

              # tab panel 5 - Company profile ----------------------------------
              
              tabPanel("Companies",
                       span("Remark: If your company is not listed here, don't hesitate to ",
                            actionLink("link_CI_to_Contact", "contact"),
                            "us or fill out the ", 
                            actionLink("link_CI_to_questionaire1", "form"), 
                            " to add your company to this list.", style = 'font-size:16px;'),
                       br(),
                       br(),
                       actionButton("link_CI_to_VC", "<< Go back to Value chain", style="float:left; color: #fff; background-color: #823F54; border-color: #823F54"),
                       actionButton("link_CI_to_EI", ">> Go to Employee information", style="float:right; color: #fff; background-color: #823F54; border-color: #823F54"),
                       br(),
                       br(),
                       hr(style="border-color: #823F54;"),
                       
                       sidebarLayout(sidebarPanel(selectInput("Company",                       
                                                              label = "Select company",
                                                              choices = data_CM[,-c(3,10,14)]$Company)
                                                  ),
                                     mainPanel(uiOutput("text0"),
                                               fluidRow(box(width=3, strong("Type:")), box(width=8, uiOutput("text1"))),
                                               fluidRow(box(width=3, strong("Description:")), box(width=8, uiOutput("text2"))),
                                               fluidRow(box(width=3, strong("Founders:")), box(width=8, uiOutput("text3"))),
                                               fluidRow(box(width=3, strong("Year Founded:")), box(width=8, uiOutput("text4"))),
                                               fluidRow(box(width=3, strong("Contact:")), box(width=8, uiOutput("text5"))),
                                               fluidRow(box(width=3, strong("Website:")), box(width=8, uiOutput("text6"))),
                                               fluidRow(box(width=3, strong("State:")), box(width=8, uiOutput("text7"))),
                                               fluidRow(box(width=3, strong("City:")), box(width=8, uiOutput("text8"))),
                                               fluidRow(box(width=3, strong("Country:")), box(width=8, uiOutput("text9"))),
                                               fluidRow(box(width=3, strong("Locations Regions:")), box(width=8, uiOutput("text10"))),
                                               fluidRow(box(width=3, strong("Operating Regions:")), box(width=8, uiOutput("text11"))),
                                               fluidRow(box(width=3, strong("Technology Focus:")), box(width=8, uiOutput("text12"))),
                                               fluidRow(box(width=3, strong("Company Focus:")), box(width=8, uiOutput("text13"))),
                                               fluidRow(box(width=3, strong("Product Type:")), box(width=8, uiOutput("text14"))),
                                               fluidRow(box(width=3, strong("Animal Type Analog:")), box(width=8, uiOutput("text15"))),
                                               fluidRow(box(width=3, strong("Ingredient Type:")), box(width=8, uiOutput("text16"))),
                                               fluidRow(box(width=3, strong("Parent Company:")), box(width=8, uiOutput("text17"))),
                                               fluidRow(box(width=3, strong("Researcher Name:")), box(width=8, uiOutput("text18"))),
                                               fluidRow(box(width=3, strong("Position:")), box(width=8, uiOutput("text19"))),
                                               fluidRow(box(width=3, strong("Host Institution:")), box(width=8, uiOutput("text20"))),
                                               fluidRow(box(width=3, strong("Research focus:")), box(width=8, uiOutput("text21"))),
                                               fluidRow(box(width=3, strong("Collaboration opportunities:")), box(width=8, uiOutput("text22"))))
                                    )
                        ),
              
              # tab panel 6 - Employee profile ----------------------------
              
              tabPanel("People",
                       span("Remark: If you want to add your profile to our webpage, don't hesitate to ",
                            actionLink("link_EI_to_Contact", "contact"),
                            "us or fill out the ", 
                            actionLink("link_EI_to_questionaire2", "form"), 
                            " to add your profile to this list.", style = 'font-size:16px;'),
                       br(),
                       br(),
                       actionButton("link_EI_to_CI", "<< Go back to Company information", style="float:left; color: #fff; background-color: #823F54; border-color: #823F54"),
                       br(),
                       br(),
                       hr(style="border-color: #823F54;")
                       ),

              # tab panel 7 - Contact ----------------------------------
              
              navbarMenu("About",
                         
                         tabPanel("Questionnaire",
                                  # Define shiny UI
                                  shinysurveys::surveyOutput(survey_questions_merged,
                                               survey_title = "Questionnaire",
                                               survey_description = "Dear Cultured Meat Enthusiast, to add your
                                                                     company or institution to the webpage, please fill out the following survey (~4min).
                                                                     Your data will then be checked and added to the database.
                                                                                          Best regards,
                                                                                          ADEA Team",
                                               theme = " #FFFFFF")
                                  ),
                         
                        tabPanel("Contact", 
                                 h1("Visit Us at TUM"),
                                 fluidRow(box(width=5, h4("We work and research at Technical University Munich.")),
                                          box(width=7, uiOutput("contactlink")))
                                 )
                        ),
                                 

         
              # Share on social media buttons ----------------------------------
             
               header = tagList(tags$h5("Share on", style = "position: relative; top: -3px; right: -1460px;"), #, align = "right"
                                tags$a(img(src="https://cdn-icons-png.flaticon.com/512/174/174848.png", height='25', width='25', style = "position: relative; top: -3px; right: -1500px;"),  
                                      href="https://facebook.com/sharer.php"),
                               tags$a(img(src="https://upload.wikimedia.org/wikipedia/commons/4/4f/Twitter-logo.svg", height='25', width='25', style = "position: relative; top: -3px; right: -1440px;"),  
                                     href="https://twitter.com/share"),
                               tags$a(img(src="https://brand.linkedin.com/content/dam/me/business/en-us/amp/brand-site/v2/bg/LI-Bug.svg.original.svg", height='25', width='25', style = "position: relative; top: -3px; right: -1380px;"), 
                                     href="https://www.linkedin.com/feed/")
                               )
    )           
  )    
) 
