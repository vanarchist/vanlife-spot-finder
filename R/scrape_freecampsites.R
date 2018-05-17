# freecampsites.net Scraper

library(jsonlite)
library(rvest)

# generate freecampsites.net URL to scrape from state specification for US only
freecampsites_generate_url <- function(state_name){
  # Error out if an invalid state is specified
  if (!state_name %in% state.name) {
    stop("Invalid state name")
  }
  paste0("https://freecampsites.net/wp-content/themes/freecampsites/",
         "androidApp.php?region=", state_name, "&advancedSearch={}")
}

# Scrape data from given url
# return data frame of location data
freecampsites_scrape_url <- function(url) {

  # Attempt to crawl, use useragent to simulate browser
  uastring <- paste("Mozilla/5.0 (Macintosh; Intel Mac OS X 10.6; rv:45.0)",
                     "Gecko/20100101 Firefox/45.0)", sep = " ")

  session <- html_session(url, user_agent(uastring),
                          add_headers(Host = "freecampsites.net",
                                      Referer = "https://freecampsites.net/"))

  # Extract location data
  json_string <- rawToChar(session$response$content)
  freecampsites_json <- fromJSON(json_string)
  freecampsites <- data.frame(freecampsites_json$resultList$latitude,
                              freecampsites_json$resultList$longitude,
                              freecampsites_json$resultList$name,
                              freecampsites_json$resultList$url)
  names(freecampsites) <- c("lat", "lon", "title", "url")
  freecampsites$type <- free_campsite_type_id()
  freecampsites
}

# scrape and save to db an individual state
freecampsites_save_state <- function(state_name, mgr){
  url <- freecampsites_generate_url(state_name)
  state_points <- freecampsites_scrape_url(url)
  save_points(mgr, state_points)
  # put a delay in so we're not sending requests too fast
  Sys.sleep(5)
}

# scrape all states in US and save
scrape_united_states <- function(){
  poi_manager <- point_of_interest()
  lapply(state.name, freecampsites_save_state, poi_manager)
  point_of_interest_destructor(poi_manager)
}
