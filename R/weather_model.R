# Weather Model
# Functions for loading, saving, and computing on temperature normal data

library(sp)
library(dismo)
library(raster)
library(maptools)
library(rgdal)

# Calculate Thiessen polygons from US temperature normals data
generate_weather_model <-function(max_normals, min_normals){
  # merge min and max normals as locations are the same
  temp_normals <- left_join(max_normals, min_normals[1:13], by = c("id"="id"),
                            suffix= c(".max", ".min"))

  # get only US weather station data
  us_temp_normals <- temp_normals[temp_normals$state
                                          %in% state.abb,]
  us_temp_normals <- us_temp_normals[startsWith(us_temp_normals$id,
                                                        "US"),]

  # load simple world map data for clipping polgons
  data("wrld_simpl", package="maptools")

  # prepare normals data for prximity polygon calculation and clipping
  dsp <- SpatialPoints(us_temp_normals[,15:14], proj4string=CRS(
                                                    proj4string(wrld_simpl)))
  dsp <- SpatialPointsDataFrame(dsp, us_temp_normals)

  # get only US borders for clipping
  us <- wrld_simpl[wrld_simpl$ISO3 == "USA",]

  # calculate Thiessen polygons
  v <- voronoi(dsp)

  # clip Thieseen polygons to US borders
  out <- crop(v, us, byid=TRUE)
}

# Save with shapefile as we need to write a SpatialDataFrame
save_weather_model <- function(model){
  shapefile(model, file_path("weather_model.Rdata"), overwrite=TRUE)
}

# Load with shapefile as we need to read a SpatialDataFrame
load_weather_model <- function(){
  shapefile(file_path("weather_model.Rdata"))
}

# utility function for getting path to data directory
file_path <- function(filename){
  if(basename(getwd()) == "R"){
    path <- paste0(rprojroot::find_root("DESCRIPTION"), "/",
                      "inst/vanlife-spot-finder/data/", filename)
  }
  else{
    path <- paste0(rprojroot::find_root("app.R"), "/",
                      "data/", filename)
  }
  path
}

# Combine min and max temp normals into single SpatialDataFrame, generate
# model, and save
combine_min_max_temps <- function(){
  max_temp_normals <- get_combined_data_max()
  min_temp_normals <- get_combined_data_min()
  normals_model <- generate_weather_model(max_temp_normals, min_temp_normals)
  save_weather_model(normals_model)
}

# Given input month (1-12) and max and min temps
# return SpatialDataFrame with polygons and temp data
filter_month_temp_data <- function(normals_model, month_int, max_temp, min_temp){
  # offset into dataframe for month columns
  max_month_idx <- month_int+1
  min_month_idx <- month_int+22

  filtered <- normals_model[(normals_model@data[, max_month_idx] <= max_temp &
                             normals_model@data[, min_month_idx] >= min_temp),]
}

# Get temperature labels for leaflet polygons
filter_month_temp_labels <- function(df, month_int){
  labels <- as.character(paste0("Max: ", df@data[,month_int+1],
                                "  Min: ", df@data[,month_int+22]))
}
