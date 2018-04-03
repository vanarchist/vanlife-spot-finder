#
# Vanlife Spot Finder
#
# The spot finder currently includes data for the state of Washington. 
# Data sources include freecampsites.net and campendium.com for campsites and 
# anytimefitness.com for gym locations.
#

library(shiny)
library(leaflet)

# UI definition
ui <- bootstrapPage(
  tags$head(
    includeCSS("www/style.css")
  ),
  tags$style(type = "text/css", "html, body {width:100%;height:100%}"),
  leafletOutput("map", width = "100%", height = "100%"),
  absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
                draggable = TRUE, top = 5, left = "auto", right = 5,
                bottom = "auto", width = 330, height = "auto",
                sliderInput("range", "Radius from gym (miles)", 1, 40,
                            value = 10, step = 1)
  )
)
  
# Server logic
server <- function(input, output, session) {

  # Load dataframes written by scraping tools
  load("data/data.RData")

  # Perform default filtering of campsites within 10 miles of a gym.
  # Convert meters to miles for units
  filtered_campendium <- campendium_data[campendium_data$min_distance
                                         <= 10 * 1609, ]
  filtered_freecampsites <- freecampsites_data[freecampsites_data$min_distance
                                               <= 10 * 1609, ]

  # Filter campendium sites when user adjusts control
  f_campendium <- reactive({
    campendium_data$radius <- input$range * 1609
    filtered_campendium <- campendium_data[campendium_data$min_distance
                                           <= input$range, ]
  })

  # Filter freecampsites sites when user adjusts control
  f_freecampsites <- reactive({
    freecampsites_data$radius <- input$range * 1609
    filtered_freecampsites <- freecampsites_data[
      freecampsites_data$min_distance <= input$range, ]
  })

  # Draw map
  output$map <- renderLeaflet({
    leaflet() %>%
      addTiles() %>%  # Add default OpenStreetMap map tiles
      addCircleMarkers(lng = gym_locations$lon, lat = gym_locations$lat,
                       popup = gym_locations$address, color = "blue",
                       radius = 6, group = "gyms") %>%
      addCircleMarkers(lng = filtered_campendium$longitude,
                       lat = filtered_campendium$latitude,
                       popup = filtered_campendium$title, color = "red",
                       radius = 6, group = "campendium") %>%
      addCircleMarkers(lng = filtered_freecampsites$longitude,
                       lat = filtered_freecampsites$latitude,
                       popup = filtered_freecampsites$name, color = "red",
                       radius = 6, group = "freecampsites")
  })

  # Update campendium sites when user adjust control
  observe({
    leafletProxy("map", data = f_campendium()) %>%
      clearGroup("campendium") %>%
      addCircleMarkers(lng = ~longitude,
                       lat = ~latitude,
                       popup = ~title,
                       color = "red",
                       radius = 6,
                       group = "campendium")
  })

  # Update freecampsites when user adjusts control
  observe({
    leafletProxy("map", data = f_freecampsites()) %>%
      clearGroup("freecampsites") %>%
      addCircleMarkers(lng = ~longitude,
                       lat = ~latitude,
                       popup = ~name,
                       color = "red",
                       radius = 6,
                       group = "freecampsites")
  })
}

# Run the application  
shinyApp(ui, server)
