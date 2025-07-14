⚠️ Hinweis zur Datenverfügbarkeit

Dieses Repository basiert auf einem Projekt, das im Rahmen des Innovationslabor Big Data Science Project im Sommersemester SS2023 durchgeführt wurde zur Marktanalyse zum Bereich kultiviertes Fleisch . Aus datenschutzrechtlichen Gründen wurden alle personenbezogenen Daten, sensible Informationen sowie proprietäre Rohdaten aus diesem Repository entfernt.

Die enthaltenen Skripte, Modelle und Strukturen spiegeln die technische Umsetzung wider, können jedoch ohne Originaldaten nicht vollständig reproduziert werden. 

Dieses Repository dient ausschließlich der Veranschaulichung des technischen Vorgehens (z. B. Datenvorverarbeitung, Analyse, Modellierung, Visualisierung) und soll mein methodisches Vorgehen und die Struktur meiner Arbeit dokumentieren.


# Adea project

Due to lack of the information about the entire production chain of cultured meat, lack of flexibility and interactivity, lack of statistical tools that provide a good entry point for interested people and lack of cross-country comparison of the industry, we - Adea team from the LMU together with the project partners from Adea Biotech, created a web application that uses an open source data set from GFI to solve these problems. This web application allows the users to have an overview of the cultured meat market which includes statistical plots, the distribution of cultured meat companies worldwide, and the distribution of cultured meat companies in the cultured meat value chain. As partnerships across the value chain plays an important role in this new industry, this webapp helps its users to find potential partners/collaborators.

![Alt text](https://github.com/thuyptt/InnoLab-Adea/blob/main/my_app/www/app_screenshot_updated.png)

## Structure of our repository:
- **datasets**: This folder includes 2 subfolders, raw_datasets and final_datasets. The subfolder **raw_datasets** includes 6 original company datasets from GFI and some sample datasets from Brightdata. The subfolder **final_datasets** includes the merged data from the 6 original data sets in the raw_datasets subfolder and two data templates. One is for company data and one is for people data.

- **my_app**: This folder includes 7 .R files which used to create our web application. The explanation for each file is written below. The subfolder **www** stores all the images which used for the frontend of our webapp.

- **my_app_modifiable_version**: This folder is a copy version of the **my_app** folder and additionally contains 2 further R markdown files, one to recreate all the plots and tables used in the shiny web application and one to modify the ui and the server at the same time. A template to create new tabs and to add new functionalities is already prepared in this last R markdown.

## Instruction:
### How to run the webapp?
In order to run the webapp, here are some explanations of the .R files in my_app folder.

- **data_merging.R**: There are 6 original company datasets which are stored in the datasets folder. This .R file is used for merging all them together (cleaning data is also part of this file).
- **google_data_prep.R**: This .R file is used to add new data from users who filled out the questionnaire to the final data set and convert the new data format to the format required for the final dataset.
- **final_data_prep.R**: This .R file is used to merge the merged dataset from data_merging.R and the new data we receive from the user to create a final dataset, which is then used for the Webapp.
- **questionnaire_company.R**: This .R code was written to create the questionnaire in order to record the new cultured meat company's information. 
- **questionnaire_employee.R**: This .R code was written to create the questionnaire in order to record the new cultured meat company's employee's information.
- **ui.R**: This file is used to define the user interface of the webapp.
- **server.R**: The server function contains the instructions that the computer needs to build our webapp.

In conclusion, **ui.R** and **server.R** are two main parts required to run the webapp. All R packages needed to run the web application are listed below. In order to run our webapp, you need to change the **path**, where your files are stored, in all of the .R files mentioned above. Then run the code below:
```
shiny::runApp('GitHub/InnoLab-Adea/my_app')
```
### How to add the new data to the webapp in the future?
In order to add the new data to the webapp, there are two options:

1/ Add the new data manually in the template which was already created in the datasets/final_datasets folder. Run the ui.R or the server.R to update the data to the webapp.

2/ Fill out the questionnaire form in the webapp. The added data will be stored in a google sheet (only the admin will have access to this google sheet). The admin will need to use the google_data_prep.R file to transform the data into orignial form and use runApp("my_app") to update the data to the webapp.

## References:
- Kamalapuram, S. K., Handral, H., & Choudhury, D. (2021). Cultured Meat Prospects for a Billion! Foods, 10(12), 2922. https://doi.org/10.3390/foods10122922
- The Good Food Institute, Introduction to cultivated meat, accessed 05 December 2022, https://gfi.org/science/the-science-of-cultivated-meat/.
- The Good Food Institute, Alternative protein manufacturers and brands, accessed 05 December 2022, https://gfi.org/resource/alternative-protein-company-database/#manufacturers-and-brands. 
- The Good Food Institute, Growing meat sustainably: the cultivated meat revolution, accessed 05 December 2022, https://gfi.org/wp-content/uploads/2021/01/sustainability_cultivated_meat.pdf. 

### All R packages which used to create webapp can be found in DESCRIPTION


## Link to our repository:
https://github.com/thuyptt/InnoLab-Adea

## Participants:
#### Thuy Ngoc Phuong Ta
#### Thi Thuy Pham
#### Luyang Chu

[![R-CMD-check](https://github.com/thuyptt/InnoLab-Adea/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/thuyptt/InnoLab-Adea/actions/workflows/R-CMD-check.yaml)
