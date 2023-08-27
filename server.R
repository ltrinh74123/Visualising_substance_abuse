#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#
library(shiny)
library(sf)
library(rgdal)
library(readxl)
library(tidyverse)
library(leaflet)

aussie_sf <- st_read("data/simplified_data/aussie_state_sf.shp")


# Define server logic required to draw a histogram
function(input, output, session) {
  output$aussie_map = renderLeaflet({
    
    mylabels <- paste(
      "<strong>", aussie_sf_simplied$STE_NAME21, "</strong>", 
      "<br/>", "Drug induced deaths: ", aussie_sf_simplied$total_deaths) %>%
      lapply(htmltools::HTML)
    
    
    pal <- colorNumeric(
      palette = "plasma",
      domain = aussie_sf_simplied$total_deaths,
      reverse = TRUE)
    
    
    m = leaflet(aussie_sf_simplied) %>%
      addPolygons(stroke = TRUE, 
                  fillOpacity = 0.5,
                  color = 'black',
                  dashArray = "3",
                  weight = 1,
                  fillColor = ~pal(total_deaths),
                  highlightOptions = highlightOptions(
                    weight = 3,
                    color = "navy",
                    dashArray = "",
                    fillOpacity = 0.7,
                    bringToFront = TRUE),
                  label = mylabels,
                  labelOptions = labelOptions(
                    style = list("font-weight" = "normal", 
                                 padding = "3px 8px"),
                    textsize = "15px",
                    direction = "auto")) %>%
      addProviderTiles(providers$CartoDB.Positron)
    
    m %>% addLegend(pal = pal, 
                    values = ~total_deaths, 
                    opacity = 0.7,
                    position = "bottomright", 
                    title = "Number of deaths") %>% 
      setView(lng = 133.0, lat = -25.0, zoom = 3)
    
      
    })
  

}
