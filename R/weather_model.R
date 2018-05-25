# Weather Model
# Functions for loading, saving, and computing on temperature normal data

library(sp)
library(dismo)
library(raster)
library(maptools)
library(rgdal)

# Calculate Thiessen polygons from US temperature normals data
generate_weather_model <-function(){
  # import temperature normals data from files
  max_temp_normals <- get_combined_data_max()

  # get only US weather station data
  us_max_temp_normals <- max_temp_normals[max_temp_normals$state
                                          %in% state.abb,]
  us_max_temp_normals <- us_max_temp_normals[startsWith(us_max_temp_normals$id,
                                                        "US"),]

  # load simple world map data for clipping polgons
  data("wrld_simpl", package="maptools")

  # prepare normals data for prximity polygon calculation and clipping
  dsp <- SpatialPoints(us_max_temp_normals[,15:14], proj4string=CRS(
                                                    proj4string(wrld_simpl)))
  dsp <- SpatialPointsDataFrame(dsp, us_max_temp_normals)

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
  #save(model,file=file_path("weather_model.Rdata"))
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
