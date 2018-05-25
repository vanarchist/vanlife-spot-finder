#
# Vanlife Spot Finder
#
# The spot finder currently includes data for most of the united states.
# Data sources include freecampsites.net for campsites and
# anytimefitness.com for gym locations.
#

library(shiny)
library(shinyBS)
library(leaflet)
library(vanlife)

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
    HTML('<button data-toggle="collapse" data-target="#demo" type="button" class="btn btn-link"><span class="glyphicon glyphicon-minus"></span></button>'),
    tags$div(id = 'demo',  class="collapse in",
    tabsetPanel(
      tabPanel("Mode", fluid = FALSE,
        selectInput("select", label = "Mode:",
          choices = list("Reported Spot")),
        checkboxGroupInput("sources", "Data Sources:",
                           c("freecampsites.net" = "fc"),
                           selected = "fc"),
        selectInput("variable", "Point Of Interest:",
                    list("Gyms (shower/bathroom)" =
                    c( "Anytime Fitness", ""))),
        sliderInput("range", "Distance from point of interest (miles)",
                    1, 40, value = 10, step = 1)
      ),
      tabPanel("Weather", fluid = FALSE,
        checkboxInput("enable_weather", "Enable", FALSE),
        sliderInput("month", "Month",
                    1, 12, value = 6, step = 1),
        sliderInput("max_temp", "Maximum Temperature (deg F)",
                    40, 90, value = 65, step = 1),
        sliderInput("min_temp", "Minimum Temperature (deg F)",
                    32, 60, value = 38, step = 1)
        )
      )
    )
  )
)

# Server logic
server <- function(input, output, session) {

  poi_mgr <- point_of_interest()

  anytime_gyms <- na.omit(get_points_all(
                  poi_mgr, anytime_fitness_type_id()))

  # Perform default filtering of campsites within 10 miles of a gym.
  filtered_freecampsites <- get_points_within_distance_by_types(poi_mgr,
                            10,
                            anytime_fitness_type_id(),
                            free_campsite_type_id())

  # Load weather normals
  normals_model <- load_weather_model()

  # Perform default filtering of temperature normals
  filtered_temp_normals <- filter_month_temp_data(normals_model, 6, 65, 38)

  # Filter freecampsites sites when user adjusts control
  f_freecampsites <- reactive({
    filtered_freecampsites <- get_points_within_distance_by_types(poi_mgr,
                              input$range,
                              anytime_fitness_type_id(),
                              free_campsite_type_id())
  })

  # Filter temperature normals when user adjusts control
  f_temp_normals <- reactive({
    filtered_temp_normals <- filter_month_temp_data(normals_model,
                                                    input$month,
                                                    input$max_temp,
                                                    input$min_temp)
  })

  # Draw map
  output$map <- renderLeaflet({

    leaflet() %>%
      addTiles() %>%  # Add default OpenStreetMap map tiles
      setView(lng= -122.3, lat = 47.6, zoom = 8) %>%
      addCircleMarkers(lng = anytime_gyms$lon, lat = anytime_gyms$lat,
                       popup = anytime_gyms$title, color = "blue",
                       radius = 6, group = "gyms") %>%
      addCircleMarkers(lng = filtered_freecampsites$longitude,
                       lat = filtered_freecampsites$latitude,
                       popup = filtered_freecampsites$title, color = "red",
                       radius = 6, group = "freecampsites")
  })

  # Update weather normals when user enables/disables or changes parameters
  observe({
    proxy <- leafletProxy("map", data = f_temp_normals())
    proxy %>% clearGroup("normals")
    if(input$enable_weather == TRUE){
      proxy %>% addPolygons(weight = 1, highlight = highlightOptions(
        weight = 5, color= "#666",
        dashArray = "", fillOpacity = 0.7,
        bringToFront = FALSE),
        label = filter_month_temp_labels(f_temp_normals(), input$month),
        group = "normals")
    }
  })

  # Update freecampsites when user adjusts control
  observe({
    proxy <- leafletProxy("map", data = f_freecampsites())
    proxy %>% clearGroup("freecampsites")
    if ("fc" %in% input$sources){
      proxy %>% addCircleMarkers(lng = ~longitude,
                                 lat = ~latitude,
                                 popup = ~title,
                                 color = "red",
                                 radius = 6,
                                 group = "freecampsites")
    }
  })
}

# Run the application
shinyApp(ui, server)
