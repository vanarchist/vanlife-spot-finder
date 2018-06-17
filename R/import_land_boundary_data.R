# Import Land Boundary Data
# For now just National Forests
# Get national forest boundaries
# Get roads labeled "National Forest" or "NF"

library(osmdata)

# Download XML file?
save_all_national_forest_data <- function(){
  # osmdata_xml(q1, "data.xml")
}

# Load data from XML file?
load_all_national_forest_data <- function(){
  # x <- osmdata_sf(q1, "data.xml")
}

# Get national forest road data for area from server
get_national_forest_roads_online <- function(bounds){
  q0 <- opq(bbox = bounds, timeout = 60)
  q1 <- add_osm_feature(q0, key = 'name', value = "^National Forest", value_exact = FALSE)
  x <- osmdata_sp(q1)

  # not sure why this is needed since proj string appears to be same?
  t <- spTransform(x$osm_lines,
                   CRS("+ellps=WGS84 +proj=longlat +datum=WGS84 +no_defs"))
}

# Get national forest boundary data from server
get_national_forest_boundaries_online <- function(bounds){
  q0 <- opq(bbox = bounds, timeout = 60)
  q1 <- add_osm_feature(q0, "operator", "United States Forest Service")
  x <- osmdata_sp(q1)

  # not sure why this is needed since proj string appears to be same?
  t <- spTransform(x$osm_multipolygons,
                   CRS("+ellps=WGS84 +proj=longlat +datum=WGS84 +no_defs"))

  # need this also
  slot(t, "polygons") <- lapply(slot(t, "polygons"), checkPolygonsHoles)
  t
}
