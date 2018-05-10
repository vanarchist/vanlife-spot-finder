#
# Anytime Fitness Scraper
#
# The anytime fitness scraper scrapes gym locations in the United States from
# the anytime fitness website locations page.
#

library(rvest)
library(ggmap)
library(DBI)

# generate anytime fitness URL to scrape from state specification for US only
generate_url <- function(state_abbreviation) {
  # Error out if an invalid state is specified
  if (!state_abbreviation %in% tolower(state.abb)) {
    stop("Invalid state abbreviation")
  }
  paste0("http://www.anytimefitness.com/locations/us/", state_abbreviation)
}
