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
library(sp)
library(rgdal)
library(readxl)
library(tidyverse)
library(plotly)
library(leaflet)

background_colour = "#1C1E22"
# setwd("/Users/linh/Documents/Github/Visualising_substance_abuse")
aussie_sf <- st_read("data/cleaned_data/aussie_state_sf.shp")

age_group = read.csv("data/cleaned_data/age_group.csv") 
recent_gender = read.csv("data/cleaned_data/gender.csv")

drug_type_age = read.csv("data/cleaned_data/drug_type_age_wo_ketamine.csv")
drug_type_age

# Define server logic required to draw a histogram
function(input, output, session) {
  rv_shape <- reactiveVal(FALSE) # whether a click happened on polygon
  rv_location = reactiveValues(id= "New South Wales")
  
  output$description = renderUI({
    paste("<strong> Proportion of recent substance users based on gender </strong> 
          displays the population percentage who used substances within in the past year for various sexes.",
          "</br></br>",
          "<strong> Proportion of recent users and average starting age for lifelong use </strong> 
          shows the selected substance users percentage within a state and the average starting age.",
          "</br></br>",
          "<strong> Proportion of recent substance users based on age groups </strong> 
          displays the distribution of users over the past year by age group and how it has evolved over time."
          ) %>% lapply(htmltools::HTML)
  })
  
  output$map_land = renderLeaflet({
    mylabels <- paste(
      "<strong>", aussie_sf$state, "</strong>", 
      "<br/>", "Drug induced deaths: ", aussie_sf$deaths) %>%
      lapply(htmltools::HTML)
    
    
    pal <- colorNumeric(
      palette = "plasma",
      domain = aussie_sf$deaths,
      reverse = TRUE)
    
    
    m = leaflet(aussie_sf) %>%
      addPolygons(stroke = TRUE, 
                  fillOpacity = 0.5,
                  color = 'black',
                  dashArray = "3",
                  weight = 1,
                  fillColor = ~pal(deaths),
                  layerId = paste0(aussie_sf$state),
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
      addProviderTiles(providers$CartoDB.Positron, options = providerTileOptions(opacity = 0.55))
    
    m %>% addLegend(pal = pal, 
                    values = ~deaths, 
                    opacity = 0.7,
                    position = "bottomright", 
                    title = "Deaths") %>% 
      setView(lng = 133.0, lat = -25.0, zoom = 3)
  })
  
  output$gender_states = renderPlotly({
    gender_state <- recent_gender %>% filter(state == rv_location$id)
    ymax_value = max(gender_state$Males, gender_state$Females) *1.15
    
    
    fig = plot_ly(data = gender_state) %>% 
      add_trace(x = ~year, 
                y = ~Males,
                type = 'bar',
                name = "Male",
                text = ~Males,
                marker = list(color = '#7eb0d5')) %>%
      add_trace(x = ~year,
                y = ~Females,
                type = 'bar',
                name = "Female",
                text = ~Females,
                marker = list(color = "#fd7f6f")) %>% 
      layout(title = list(font = list(color = "lightgrey")),
             paper_bgcolor=background_colour, plot_bgcolor=background_colour,
             xaxis = list(
               title = list(text = "Years", font = list(color = "lightgrey")),
               tickcolor = 'lightgrey',
               linecolor = "lightgrey",
               tickfont = list(color = "lightgrey")),
             yaxis = list(
               title = list(text = "Proportion (%)", font = list(color = "lightgrey")),
               gridcolor = 'rgba(200, 200, 200, 0.2)' ,
               showgrid = TRUE,
               showline = T,
               showticklabels = TRUE,
               tickcolor = 'lightgrey',
               linecolor = "lightgrey",
               tickfont = list(color = "lightgrey"),
               ticks = 'outside',
               zeroline = TRUE,
               range = c(0, ymax_value)),
             barmode = 'group', bargap = 0.15, bargroupgap = 0.1,
             legend = list(font = list(color = "lightgrey"),
                           x = 0, y = 1,
                           orientation = 'h'))
    
  })
  #### observe mouse events ####
  # ## update rv when the selection of state changes
  output$ui_county <- renderUI({
    HTML(paste(rv_location$id))
  })
  
  output$age_group = renderPlotly({
    age_group <- age_group %>% filter(state == rv_location$id)
    ymax_value = max(age_group[3:9]) *1.15
    years = age_group$year
    plot_ly() %>% add_trace(data = age_group, 
                            x = ~year,
                            y = ~X14.17,
                            type ="scatter",
                            mode = "lines",
                            name = "14-17", 
                            connectgaps = TRUE,
                            line = list(color = "#fd7f6f", width = 3)) %>% 
      add_trace(data = age_group, 
                x = ~year,
                y = ~X18.24,
                type ="scatter",
                mode = "lines",
                name = "18-24", 
                connectgaps = TRUE,
                line = list(color = "#7eb0d5", width = 3)) %>%
      add_trace(data = age_group, 
                x = ~year,
                y = ~X25.29,
                type ="scatter",
                mode = "lines",
                name = "25–29", 
                connectgaps = TRUE,
                line = list(color = "#b2e061", width = 3)) %>%
      add_trace(data = age_group, 
                x = ~year,
                y = ~X30.39,
                type ="scatter",
                mode = "lines",
                name = "30–39", 
                connectgaps = TRUE,
                line = list(color = "#bd7ebe", width = 3)) %>%
      add_trace(data = age_group, 
                x = ~year,
                y = ~X40.49,
                type ="scatter",
                mode = "lines",
                name = "40–49", 
                connectgaps = TRUE,
                line = list(color = '#ffb55a', width = 3)) %>%
      add_trace(data = age_group,
                x = ~year,
                y = ~X50.59,
                type ="scatter",
                mode = "lines",
                name = "50-59", 
                connectgaps = TRUE,
                line = list(color = "#fdcce5", width = 3)) %>%
      add_trace(data = age_group,
                x = ~year,
                y = ~X60.,
                type ="scatter",
                mode = "lines",
                name = "60+", 
                connectgaps = TRUE,
                line = list(color = "#8bd3c7", width = 3)) %>%
      layout(yaxis = list(range = c(0, ymax_value))) %>%
      layout(title = list(font = list(color = "lightgrey")),
             paper_bgcolor=background_colour, plot_bgcolor=background_colour,
             xaxis = list(title = list(text = "Years", font = list(color = "lightgrey")),
                          gridcolor = 'rgba(200, 200, 200, 0.2)' ,
                          showgrid = T,
                          showline = TRUE,
                          showticklabels = TRUE,
                          tickcolor = 'lightgrey',
                          linecolor = "lightgrey",
                          tickfont = list(color = "lightgrey"),
                          ticks = 'outside',
                          zeroline = TRUE,
                          tickvals = years,
                          ticktext = years),
             yaxis = list(title = list(text = "Proportion (%)", font = list(color = "lightgrey")),
                          gridcolor = 'rgba(200, 200, 200, 0.2)' ,
                          showgrid = TRUE,
                          showline = T,
                          showticklabels = TRUE,
                          tickcolor = 'lightgrey',
                          linecolor = "lightgrey",
                          tickfont = list(color = "lightgrey"),
                          ticks = 'outside',
                          zeroline = TRUE),
             legend = list(font = list(color = "lightgrey")))
  }

  ## Drug types    
  )
  drug_type_age_df = reactive({
    data = drug_type_age %>% select(year, state, all_of(input$drug_name), label)
    data = data %>% filter(state == rv_location$id)
    data = data %>% pivot_wider(names_from = label, values_from = all_of(input$drug_name))
    data
  })
  
  output$table = renderDataTable(drug_type_age_df())

  output$drug_type= renderPlotly({
    max_mean_age = max(drug_type_age_df()$mean_age)
    max_usage = max(drug_type_age_df()$proportion)
    fig = plot_ly(data = drug_type_age_df(),
                  x = ~as.factor(year),
                  y = ~proportion,
                  type = "bar",
                  name = "Users \nproportion (%)",
                  marker = list(color = "#bd7ebe")
    )  %>% 
      add_trace(x = ~as.factor(year), 
                y = ~mean_age, 
                name = "Mean \nstarting \nage",
                type = "scatter",
                mode = "lines+markers",
                yaxis = "y2",
                line = list(color = "#ffb55a"),    # Change line color
                marker = list(color = "#ffb55a"))
    
    ay <- list(
      overlaying = "y",
      side = "right",
      title = list(text = "Mean Initialisation Age", font = list(color = "lightgrey")),
      range = c(0, max_mean_age *1.2),
      gridcolor = 'rgba(200, 200, 200, 0)',
      tickcolor = 'lightgrey',
      linecolor = "lightgrey",
      tickfont = list(color = "lightgrey"),
      showline = TRUE)
    
    fig = fig %>% layout(title = list(font = list(color = "lightgrey")),
                         paper_bgcolor=background_colour, plot_bgcolor=background_colour,
                         yaxis2 = ay, 
                         xaxis = list(title = list(text = "Years", font = list(color = "lightgrey")),
                                      tickcolor = 'lightgrey',
                                      linecolor = "lightgrey",
                                      tickfont = list(color = "lightgrey"),
                                      showline = TRUE),
                         
                         yaxis = list(title = list(text = "Users proportion (%)", 
                                                   font = list(color = "lightgrey")),
                                      range = c(0, max_usage *1.2),
                                      tickcolor = 'lightgrey',
                                      linecolor = "lightgrey",
                                      tickfont = list(color = "lightgrey"),
                                      gridcolor = 'rgba(200, 200, 200, 0.2)',
                                      showline = TRUE),
                         margin = list(r = 80),
                         legend = list(font = list(color = "lightgrey")))
    fig %>%
      layout(legend = list(orientation = 'h'))
  })
  
  ## when any click happens, identify clicks on map and log new location info
  observeEvent(input$map_land_click,{
    map_land_shape_click_info <- input$map_land_shape_click
    map_land_click_info <- input$map_land_click
    rv_location$id <- map_land_shape_click_info$id # take state name
    
    if (is.null(map_land_shape_click_info)){ # this happens when there hasn't been any click on polygons -> no shape click
      rv_shape(FALSE)
      
    }else if (!all(unlist(map_land_shape_click_info[c('lat','lng')]) == unlist(map_land_click_info[c('lat','lng')]))){ # this happens when there has been click on polygon
      rv_shape(FALSE)
      
    }else{
      rv_shape(TRUE)
    }
    
    
    
  })
    
  
}
