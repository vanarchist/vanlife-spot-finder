# Management functionality for the point of interest data

library(DBI)
library(RSQLite)
library(rprojroot)

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

# populate point_of_interest_type table with types
# this is used at database creation time
populate_point_of_interest_type <- function(obj){
  id <- c(anytime_fitness_type_id(),
          free_campsite_type_id())
  name <- c("Anytime Fitness", "Free Campsite")
  types <- data.frame(id, name)
  dbWriteTable(obj$db_con, "point_of_interest_type", types, overwrite = TRUE)
}

anytime_fitness_type_id <- function(){
  as.integer(1)
}

free_campsite_type_id <- function(){
  as.integer(2)
}
