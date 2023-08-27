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
library(shinythemes)
aussie_sf <- st_read("data/simplified_data/aussie_state_sf.shp")

# Define UI for application that draws a histogram
navbarPage("United",
           theme = shinythemes::shinytheme("slate"),  # <--- Specify theme here
           tabPanel("Plot",
                      leafletOutput("aussie_map")
                    )
           )

