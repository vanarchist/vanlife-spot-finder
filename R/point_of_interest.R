# Management functionality for the point of interest data

library(DBI)
library(RSQLite)
library(rprojroot)
library(geosphere)
library(matrixStats)

# constructor
point_of_interest <- function(){
  obj <- list()
  db_path <- paste0(find_root("DESCRIPTION"), "/",
                    "inst/vanlife-spot-finder/data/data.db")
  obj$db_con <- dbConnect(RSQLite::SQLite(),
                          dbname = db_path)
  class(obj) <- "point_of_interest"
  obj
}

# destructor
point_of_interest_destructor <- function(obj){
  dbDisconnect(obj$db_con)
}

# write dataframe of anytime fitness locations to spatialite db
# expects data does not exists, does not handle updates or duplicates
save_points <- function(obj, points){
  query <- paste0("INSERT INTO point_of_interest ",
                  "(latitude, longitude, title, url, type) ",
                  "VALUES(:lat, :lon, :title, :url, :type)")
  dbSendQuery(obj$db_con, query, params = list(lat = points$lat,
                                               lon = points$lon,
                                               title = points$title,
                                               url = points$url,
                                               type = points$type))
}

# get all points of a given type
get_points_all <- function(obj, type){
  dbGetQuery(obj$db_con, "SELECT * FROM point_of_interest WHERE type = :type",
             params = list(type = type))
}

# get all type2 points within specified distance type1 points
# TODO: use spatialite functions if I can get it working
get_points_within_distance_by_types <- function(obj, distance, type1, type2){
  query <- paste0("SELECT * FROM point_of_interest WHERE id IN ",
                  "(SELECT type2_id FROM min_distance_lookup ",
                  "WHERE type1 = :t1 ",
                  "AND type2 = :t2 AND min_distance <= :x)")

  filtered <- dbGetQuery(obj$db_con, query, params = list(t1 = type1,
                                                          t2 = type2,
                                                          x = distance))
}

# Precompute minimum distances from point of interest types for
# fast lookup for now since spatialite isn't working
compute_minimum_distances_between_types <- function(obj, type1, type2){

  query <- "SELECT * FROM point_of_interest WHERE type = :t1"
  type1_pts <- dbGetQuery(obj$db_con, query, params = list(t1 = type1))
  type1_pts <- na.omit(type1_pts)

  query <- "SELECT * FROM point_of_interest WHERE type = :t2"
  type2_pts <- dbGetQuery(obj$db_con, query, params = list(t2 = type2))
  type2_pts <- na.omit(type2_pts)

  # create distance matrix, convert meters to miles
  mat <- distm(type1_pts[, c("longitude", "latitude")],
               type2_pts[, c("longitude", "latitude")],
               fun = distHaversine) / 1609

  # get minimum distance from type1 to type2 points
  col_mins <- colMins(mat)

  type2_pts$min_dist <- col_mins

  # format dataframe from writing to db lookup table
  lookup <- data.frame(type2_pts$id,
                       type2_pts$min_dist)

  lookup$type1 <- as.integer(type1)
  lookup$type2 <- as.integer(type2)
  names(lookup) <- c("type2_id", "min_distance", "type1", "type2")

  # overwrite table
  # TODO: probably want to change this when more types are added
  dbWriteTable(obj$db_con, "min_distance_lookup", lookup, overwrite = TRUE)
}

# create spatialite index for faster querying
# TODO: not used now because spatialite support isn't working
index_points <- function(obj){
  query <- paste0("SELECT AddGeometryColumn(\"point_of_interest\", ",
                  "\"Geometry\", 4326, \"POINT\", \"XY\");")
  dbSendQuery(obj$db_con, query)

  query <- "SELECT CreateSpatialIndex(\"point_of_interest\", \"Geometry\");"
  dbSendQuery(obj$db_con, query)

  query <- paste0("UPDATE point_of_interest SET Geometry=MakePoint(longitude,",
                  "latitude,4326);")
  dbSendQuery(obj$db_con, query)

  query <- "ANALYZE point_of_interest;"
  dbSendQuery(obj$db_con, query)
}

# populate point_of_interest_type table with types
# this is used at database creation time
populate_point_of_interest_type <- function(obj){
  id <- c(anytime_fitness_type_id(),
          free_campsite_type_id())
  name <- c("Anytime Fitness", "Free Campsite")
  types <- data.frame(id, name)
  dbWriteTable(obj$db_con, "point_of_interest_type", types, overwrite = TRUE)
}

# id type constant for anytime fitness
anytime_fitness_type_id <- function(){
  as.integer(1)
}

# id type constant for freecampsites.net
free_campsite_type_id <- function(){
  as.integer(2)
}
