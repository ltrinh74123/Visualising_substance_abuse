#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#
library(sf)
library(leaflet)
library(shiny)
library(shinydashboard)
library(shinythemes)
library(plotly)
library(shinyWidgets)
drug_type_age = read.csv("data/cleaned_data/drug_type_age_wo_ketamine.csv")
#leafletOutput('map_land', height = 350)
# plotlyOutput("gender_states", height = 450)
# plotlyOutput("age_group"),
# radioButtons("drug_name", "Drug Type", drug_names, inline = TRUE),
# plotlyOutput("drug_type"))

drug_names = names(drug_type_age)[3:9]
# Define UI for application that draws a histogram
navbarPage("Profilling Substance Usage in Australia",
           theme = shinythemes::shinytheme("slate"),
           shinyWidgets::useShinydashboard(),
           tabPanel("Dashboard",
                    tags$style(HTML("
.box.box-solid.box-primary>.box-header {
                    color:lightgrey;
                    background:#212329
                    }

                    .box.box-solid.box-primary{
                    border-bottom-color:#212329;
                    border-left-color:#212329;
                    border-right-color:#212329;
                    border-top-color:lightblue;
                    background:#1C1E22
                    }
.box.box-solid.box-warning>.box-header {
                    color:lightgrey;
                    background:#212329
                    }

                    .box.box-solid.box-warning{
                    border-bottom-color:#212329;
                    border-left-color:#212329;
                    border-right-color:#212329;
                    border-top-color:lightcoral;
                    background:#1C1E22
                    }
                                    ")),
                    # fluidRow(column(width = 4, htmlOutput('ui_county'))),
                    fluidRow(
                      column(width = 3,
                        box(width = NULL,
                            status = "warning",
                            solidHeader = T,
                            "Click on the different states to learn more!",
                            title = uiOutput('ui_county'),
                            ),
                        box(width = NULL,
                            status = "warning",
                            solidHeader = T,
                            title = "Graphic Description",
                            htmlOutput("description"))),
                      
                      column(width = 4,
                        box(width = NULL, leafletOutput('map_land', height = 350), solidHeader = T,
                            title = "Map of deaths due to substance abuse in Australia",
                            status = "primary")
                      ),
                      column(width = 5,
                        box(width = NULL,
                        plotlyOutput("gender_states", height = 350),
                        solidHeader = T,
                        status = "primary",
                        title = "Proportion of recent substance users based on gender")),
                        
                        ),
                        fluidRow(
                          box(
                          
                          radioButtons("drug_name", "Substance Names", drug_names, inline = TRUE),
                          plotlyOutput("drug_type", height= 330),
                          solidHeader = T,
                          status = "primary",
                          title = "Proportion of recent users and average starting age for lifelong use",
                          "There is a negligible amount of data that can be correctly utilised 
                          if there is no bar or line for a given year on the graph."),
                          
                          box(
                            
                            plotlyOutput("age_group", height = 390),
                            solidHeader = T,
                            title = "Proportion of substance users based on age groups",
                            status = "primary",
                            'Click on the various legends to select or deselect any age groups for simpler comparison.',
                            width = 6                          
                            )
                          
                        
                        )))
