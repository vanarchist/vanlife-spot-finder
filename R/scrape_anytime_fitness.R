#
# Anytime Fitness Scraper
#
# The anytime fitness scraper scrapes gym locations in the United States from
# the anytime fitness website locations page.
#

library(rvest)
library(ggmap)
library(httr)

# generate anytime fitness URL to scrape from state specification for US only
generate_url <- function(state_abbreviation) {
  # Error out if an invalid state is specified
  if (!state_abbreviation %in% tolower(state.abb)) {
    stop("Invalid state abbreviation")
  }
  paste0("http://www.anytimefitness.com/locations/us/", state_abbreviation)
}

# scrape data from Anytime Fitness given URL
# returns string array of locations in format on success:
# [["City, State", "Street", "Phone", "Status"]]
scrape_url <- function(url) {

  # Attempt to crawl, use useragent to simulate browser
  uastring <- paste("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_6_8)",
                     "AppleWebKit/537.36 (KHTML, like Gecko)",
                     "Chrome/49.0.2623.112 Safari/537.36", sep = " ")
  session <- html_session(url, user_agent(uastring))

  # Extract location data
  table <- session %>%
    html_nodes("table td") %>%
    html_text() #text
}

# take scraped data and geocode locations, format for db
process_data <- function(url, location_data, api_key){
  # get second column in table (address)
  street <- location_data[seq(2, length(location_data), 4)]
  citystate <- location_data[seq(1, length(location_data), 4)]
  status <- location_data[seq(4, length(location_data), 4)]
  # remove parenthesis text from city names if it exists
  # https://stackoverflow.com/questions/13529360/
  # replace-text-within-parenthesis-in-r
  citystate <- gsub( " *\\(.*?\\) *", "", citystate)
  addresses <- paste0(street, ", ", citystate)
  processed <- geocode(addresses, source = "google", signature = google_api_key)
  processed$title <- paste0("Anytime Fitness ", "[", status, "]: ", addresses)
  processed$url <- url
  processed$type <- anytime_fitness_type_id()
  processed
}

scrape_state <- function(state_abbreviation){
  url <- generate_url(state_abbreviation)
  data <- scrape_url(url)
  points <- process_data(url, data, google_api_key)
  points
}

save_state <- function(state_abbreviation, mgr){
  state_points <- scrape_state(state_abbreviation)
  save_points(mgr, state_points)
}

scrape_united_states <- function(){
  poi_manager <- point_of_interest()
  lapply(tolower(state.abb), save_state, poi_manager)
  point_of_interest_destructor(poi_manager)
}
