# Libraries ------------------------------------------------------------------

library(devtools)
library(dplyr)
library(tidyverse)
library(treemap) # create value chain
#install_github("timelyportfolio/d3treeR")
library(d3treeR) # make the treemap interactive
library(shiny) # create shiny app
library(leaflet) # create world map
library(maps) # create world map
library(plotly)
library(viridis)# virids package for the color palette
library(mapproj)
library(ggrepel)
library(DT) # create data.table
library(ggiraph) # make the world map clickable

################################################################################

# 1. Load the dataset with CM company and all alternative protein companies ----

source(file = "~/InnoLab-Adea/my_app/final_data_prep.R")

################################################################################

# 2. Design adjustments --------------------------------------------------------

# Define color palette for the exploratory statistics 
temperatureColor <- "#E4C49D"
priceColor <- "#823F54"
  
# Define function to change font size of treemap from https://zhiyang.netlify.app/post/treemap/
style_widget <- function(hw=NULL, style="", addl_selector="") {
  stopifnot(!is.null(hw), inherits(hw, "htmlwidget"))
  
  # use current id of htmlwidget if already specified
  elementId <- hw$elementId
  if(is.null(elementId)) {# borrow htmlwidgets unique id creator
    elementId <- sprintf('htmlwidget-%s',
                         htmlwidgets:::createWidgetId())
    hw$elementId <- elementId}
  
  htmlwidgets::prependContent(hw, htmltools::tags$style(sprintf("#%s %s {%s}",
                                                                elementId,
                                                                addl_selector,
                                                                style)
                                                      )
                              )
}

################################################################################

# 3. Shiny server --------------------------------------------------------------

shinyServer(function(input, output, session) {
  
  # 3.1. Create action links/buttons to change tabs ----------------------------
  
  observeEvent(input$link_Home_to_Stat, {newvalue <- "Statistics"
                                         updateTabItems(session, "panels", newvalue)})
  observeEvent(input$link_WM_to_VC, {newvalue <- "Value Chain"
                                     updateTabItems(session, "panels", newvalue)})
  observeEvent(input$link_VC_to_WM, {newvalue <- "Worldmap"
                                     updateTabItems(session, "panels", newvalue)})
  observeEvent(input$link_VC_to_CI, {newvalue <- "Companies"
                                     updateTabItems(session, "panels", newvalue)})
  observeEvent(input$link_CI_to_VC, {newvalue <- "Value Chain"
                                     updateTabItems(session, "panels", newvalue)})
  observeEvent(input$link_CI_to_Contact, {newvalue <- "Contact"
                                          updateTabItems(session, "panels", newvalue)})
  observeEvent(input$link_CI_to_questionaire1, {newvalue <- "Questionnaire"
                                               updateTabItems(session, "panels", newvalue)})
  observeEvent(input$link_CI_to_EI, {newvalue <- "People"
                                     updateTabItems(session, "panels", newvalue)})
  observeEvent(input$link_EI_to_Contact, {newvalue <- "Contact"
                                                updateTabItems(session, "panels", newvalue)})
  observeEvent(input$link_EI_to_questionaire2, {newvalue <- "Questionnaire"
                                               updateTabItems(session, "panels", newvalue)})
  observeEvent(input$link_EI_to_CI, {newvalue <- "Companies"
                                     updateTabItems(session, "panels", newvalue)})
  
  # 3.2. Generate plot 1 and 2  ------------------------------------------------
  
  output$barplot1 <- renderPlot({
    x <- count_Year.Founded$Year.Founded
    y <- input$y
    
    ggplot(data = count_Year.Founded, aes_string(x = x, y = y))+  
      geom_bar(stat="identity", fill=temperatureColor, alpha=.4) + 
      #geom_text(aes(x, label=y), vjust=-0.3, size=3.5) + 
      theme_classic() + 
      labs(title = paste("Figure 1: Number of ", y, " cultured meat companies", ", by year founded", sep = ""), 
           x = "Year founded", 
           y = paste("Number of ", y, " cultured meat companies", sep = "")) +
      theme(axis.text = element_text(size = 16)) +
      theme(axis.title = element_text(size = 18)) +
      theme(plot.title = element_text(size = 24)) 
  })
  
  # 3.3. Generate plot 3 -------------------------------------------------------
  
  output$barplot2 <- renderPlot({
    x <- count_Year.Founded$Year.Founded
    n <- count_Year.Founded$new
    cum_n <- count_Year.Founded$total
    coeff <- 4
    
    ggplot(count_Year.Founded, aes(x=x)) +
      geom_bar(aes(y=n), stat="identity", size=.01, fill=temperatureColor, color="black", alpha=.4) + 
      geom_line(aes(y=cum_n/coeff, group = 1), size=1, color=priceColor) + 
      geom_point(aes(y=cum_n/coeff), size=2, color=priceColor) +
      geom_text(aes(y=cum_n/coeff,label=cum_n), vjust=-1, size=7) +
      geom_text(aes(y=n,label=n), vjust=-0.5, size=7) +
      scale_y_continuous(# Features of the first axis
                         name = "Number of new cultured meat companies",
                         # Add a second axis and specify its features
                         sec.axis = sec_axis(~.*coeff, name="Total number of cultured meat companies")) + 
      theme_classic() +
      theme(axis.title.y = element_text(color = "#000000", size=18),
            axis.title.y.right = element_text(color = priceColor, size=18)) +
      labs(title = "Figure 2: New and Total number of cultured meat companies, \nby year founded", 
           x = "Year") +
      theme(axis.text = element_text(size = 16)) +
      theme(axis.title = element_text(size = 18)) +
      theme(plot.title = element_text(size = 24)) 
  })
  
  # 3.4. Generate other basic plots --------------------------------------------
  
  output$barplot3 <- renderPlot({
    plot_varnumber <- which(sapply(plot_list, function(x) any(names(x) == input$x)))
    plot_vardata <- as.data.frame(plot_list[plot_varnumber])
    plots_var <- ggplot(plot_vardata, aes(x=reorder(plot_vardata[,1], + n), y=n))+  
      geom_bar(stat="identity", size=.01, fill=temperatureColor, color="black",
               alpha=.4, width = 0.8, position = position_dodge(width = 1)) + 
      geom_text(aes(label=n), hjust=-0.3, size=5) + # adding label text outside the bars
      theme_classic() + 
      coord_flip() +
      labs(title = paste("Figure 3: Number of cultured meat companies by ","", input$x, sep = ""), 
           x = input$x, y = "Number of cultured meat companies") +
      theme(axis.text = element_text(size = 16)) +
      theme(axis.title = element_text(size = 18)) +
      theme(plot.title = element_text(size = 24)) 
    plots_var 
  })

  # 3.5. Generate World map ----------------------------------------------------
  
  output$mapplot <- renderPlotly({
    p <- NumberofCMInEachCountry %>%
      ggplot() +
      geom_polygon(data = world, aes(x=long, y = lat, group=group), fill="darkgray", alpha=0.3) +
      geom_point(aes(x=long, y=lat, size=n, color=n, text=mytext, alpha=n) ) +
      geom_text_repel(data=NumberofCMInEachCountry, aes(x=long, y=lat, label=country), size=5) +
      scale_size_continuous(range=c(1,15)) +
      scale_alpha_continuous(trans="log") +
      theme_void() +
      theme(legend.position = "right") +
      labs(color='Number of cultured \nmeat companies') +
      scale_color_gradient(limits = c(0, 60),
                           breaks = c(10, 20, 30, 40, 50),
                           labels = c(10, 20, 30, 40, 50),
                           low = "#C9A204",
                           high = priceColor
                           )
    cm_worldmap <- ggplotly(p , tooltip="text", source = "plotmap")
    event_register(cm_worldmap, "plotly_click")
    cm_worldmap
  })
  
  # 3.6. Generate world map table ----------------------------------------------
  
  output$maptable <- renderDataTable({
    country_map <- event_data("plotly_click", source = "plotmap")
    if (is.null(country_map)) return(NULL)
    # Obtain the clicked x lang variables 
    tablemap <-  data_CM_merged %>% filter(long %in% country_map) %>%
      select(Country, Company, Type, Protein.Category, Location.Regions, Technology.Focus, Contact.email,              
             Website, Company.Focus, Product.Type, Animal.Type.Analog, Ingredient.Type, Operating.Regions, State,
             City, Year.Founded, Founders, Parent.Company, Researcher.name, Position, Host.Institution, Research.focus, 
             Collaboration.opportunities)
    datatable(tablemap,
              options = list(searching = FALSE,pageLength = 5,
                             lengthMenu = c(5, 10, 15, 20), scrollX = T),width = "600px" ,
              height = "800px",
              colnames = c("Country","Company", "Type", "Protein Category" 
                           ,"Location Regions" 
                           ,"Technology Focus", "Contact", "Website" 
                           ,"Company Focus", "Product Type"               
                           ,"Animal Type Analog", "Ingredient Type", "Operating Regions", 
                           "State", "City", "Year founded", "Founder"         
                           ,"Parent Company", "Researcher Name"            
                           ,"Position", "Host Institution", "Research focus"             
                           ,"Collaboration opportunities"))})
  
  # 3.7. Generate Treemap ------------------------------------------------------
  
  ## The table which shows the number of CM companies in each step of the VC of selected countries
  # country/ region need multiple choice
  treemap_regiondata <- reactive({
    data_CM_VC %>% filter(Location.Regions %in% input$regionselect) %>%
                                   group_by(Technology.Focus,Location.Regions,Country,Company)
  })
  
  observeEvent(treemap_regiondata(), {
    choice_country <- unique(treemap_regiondata()$Country)
    updateSelectInput(session,"countryselect",  
                      choices = choice_country,selected = NULL)
  })
  
  
  treemap_partdata <- reactive({
    validate(need(input$regionselect != "" , "Please select at least a region"),
             need(input$countryselect != "" , "Please select at least a country"))
    data_CM_VC %>% filter(Country %in% input$countryselect) %>%
                   group_by(Technology.Focus_grouped,Technology.Focus,Company,Country,Location.Regions)
    })
  
  output$vcdis_countrytable <- renderTable({
                                  if(nrow(treemap_partdata()) == 0){
                                    newdata <- treemap_regiondata() 
                                  }
                                  else{ newdata <- treemap_partdata() 
                                  }
                                  newdata %>% group_by(Technology.Focus_grouped) %>% count(Technology.Focus_grouped) %>%
                                    rename("Technology Focus" = Technology.Focus_grouped , "Number of cultured meat companies" = n)
                                })
  
  ## Value chain per country
  output$valuechain_countplot <- renderUI({ 
    if(nrow(treemap_partdata()) == 0){
      newdata <- treemap_regiondata() %>% summarise(n = n())
    }
    else{ newdata <- treemap_partdata() %>% summarise(n = n())
    }
    tm_country <- treemap(newdata,index=c("Technology.Focus_grouped", "Technology.Focus", "Location.Regions", "Country", "Company"),
                          vSize="n",
                          vColor="Technology.Focus_grouped",
                          type="index",
                          title="Upstream value chain",
                          palette = "OrRd")
    treecountry <- style_widget(d3tree2(tm_country, rootname = "Upstream value chain", width="200%", height = "800px" ), 
                                addl_selector="text",
                                style="font-family: cursive; font-size: 20px;")
    print(treecountry)
  })
  
  # 3.8. Generate Company Profile ----------------------------------------------
  
  output$text0 <- renderUI({text0 <- data_CM$Company[which(data_CM$Company == input$Company)]
  h1(text0, align="center")})
  output$text1 <- renderUI({HTML(data_CM$Type[which(data_CM$Company == input$Company)])}) 
  output$text2 <- renderUI({HTML(data_CM$Brief.Description[which(data_CM$Company == input$Company)])}) 
  output$text3 <- renderUI({HTML(data_CM$Founders[which(data_CM$Company == input$Company)])}) 
  output$text4 <- renderUI({HTML(data_CM$Year.Founded[which(data_CM$Company == input$Company)])}) 
  output$text5 <- renderUI({HTML(data_CM$Contact.email[which(data_CM$Company == input$Company)])}) 
  output$text6 <- renderUI({a(data_CM$Website[which(data_CM$Company == input$Company)], href=data_CM$Website[which(data_CM$Company == input$Company)])}) 
  output$text7 <- renderUI({HTML(data_CM$State[which(data_CM$Company == input$Company)])}) 
  output$text8 <- renderUI({HTML(data_CM$City[which(data_CM$Company == input$Company)])}) 
  output$text9 <- renderUI({HTML(data_CM$country[which(data_CM$Company == input$Company)])}) 
  output$text10 <- renderUI({HTML(data_CM$Location.Regions[which(data_CM$Company == input$Company)])}) 
  output$text11 <- renderUI({HTML(data_CM$Operating.Regions[which(data_CM$Company == input$Company)])}) 
  output$text12 <- renderUI({HTML(data_CM$Technology.Focus[which(data_CM$Company == input$Company)])}) 
  output$text13 <- renderUI({HTML(data_CM$Company.Focus[which(data_CM$Company == input$Company)])}) 
  output$text14 <- renderUI({HTML(data_CM$Product.Type[which(data_CM$Company == input$Company)])}) 
  output$text15 <- renderUI({HTML(data_CM$Animal.Type.Analog[which(data_CM$Company == input$Company)])}) 
  output$text16 <- renderUI({HTML(data_CM$Ingredient.Type[which(data_CM$Company == input$Company)])}) 
  output$text17 <- renderUI({HTML(data_CM$Parent.Company[which(data_CM$Company == input$Company)])}) 
  output$text18 <- renderUI({HTML(data_CM$Researcher.name[which(data_CM$Company == input$Company)])}) 
  output$text19 <- renderUI({HTML(data_CM$Position[which(data_CM$Company == input$Company)])}) 
  output$text20 <- renderUI({HTML(data_CM$Host.Institution[which(data_CM$Company == input$Company)])}) 
  output$text21 <- renderUI({HTML(data_CM$Research.focus[which(data_CM$Company == input$Company)])}) 
  output$text22 <- renderUI({HTML(data_CM$Collaboration.opportunities[which(data_CM$Company == input$Company)])}) 

  # 3.9. Questionnaire ---------------------------------------------------------
  #  Questionaire_employee
  #renderSurvey()
  
  #observeEvent(input$submit, {
  #  showModal(modalDialog(title = "Thank you for supporting us."))
  #  response_data_employee <- getSurveyData(custom_id = input$Employee.Name)
    
    # Read our sheet
  #  values <- read_sheet(ss = sheet_id_employee,
  #                       sheet = "questionaire_employee")
    
    # Check to see if our sheet has any existing data.
    # If not, let's write to it and set up column names.
    # Otherwise, let's append to it.
    
   # if (nrow(values) == 0) {
  #     sheet_write(data = response_data_employee,
  #                 ss = sheet_id_employee,
  #                 sheet = "questionaire_employee")
  #   } else {
  #     sheet_append(data = response_data_employee,
  #                  ss = sheet_id_employee,
  #                  sheet = "questionaire_employee")
  #   }
  #   
  # })
  # 
  
#  Questionaire_company
  renderSurvey()

  observeEvent(input$submit, {
    showModal(modalDialog(title = "Thank you for supporting us."))
    response_data <- getSurveyData(custom_id = input$Employee.Name)

    # Read our sheet
    values <- read_sheet(ss = sheet_id,
                         sheet = "questionaire_company")

    # Check to see if our sheet has any existing data.
    # If not, let's write to it and set up column names.
    # Otherwise, let's append to it.

    if (nrow(values) == 0) {
      sheet_write(data = response_data,
                  ss = gs4_get(sheet_id),
                  sheet = "questionaire_company")
    } else {
      sheet_append(data = response_data,
                   ss = gs4_get(sheet_id),
                   sheet = "questionaire_company")
    }

  })

  # 3.10. Contact --------------------------------------------------------------
  
  url <- a("Link to our Homepage", href="https://adeabio.tech/")
  output$contactlink <- renderUI({tagList(url)})
  
})