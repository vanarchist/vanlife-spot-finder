# Import NOAA US Climate Normals 1981-2010

# Data sources
# https://www1.ncdc.noaa.gov/pub/data/normals/1981-2010/products/temperature/
# mly-tmin-normal.txt
# https://www1.ncdc.noaa.gov/pub/data/normals/1981-2010/products/temperature/
# mly-tmax-normal.txt
# https://www1.ncdc.noaa.gov/pub/data/normals/1981-2010/station-inventories/
# allstations.txt

library(rprojroot)

# Read data from NOAA normals file into dataframe
read_noaa_normals_file <- function(file){
  file_path <- paste0(rprojroot::find_root("DESCRIPTION"), "/",
                      "inst/vanlife-spot-finder/data/", file)
  data <- read.table(file_path, header = FALSE, stringsAsFactors = FALSE)
  names(data) <- c("station", "jan", "feb", "mar", "apr", "may", "jun",
                   "jul", "aug", "sep", "oct", "nov", "dec")
  data
}

# Read data from NOAA stations file into dataframe
read_noaa_stations_file <- function(file){
  file_path <- paste0(rprojroot::find_root("DESCRIPTION"), "/",
                      "inst/vanlife-spot-finder/data/", file)
  data <- read.fwf(file_path, widths = c(11, 9, 10, 7, 3, 32, 4, 4, 6),
                   header = FALSE, stringsAsFactors = FALSE, fill = TRUE,
                   col.names=c("id", "latitude", "longitude", "elevation", "state",
                               "name", "gsnflag", "hcnflag", "wmoid", "method"))
  data
}

# Process data to get in usable format
# Data format specified in:
# https://www1.ncdc.noaa.gov/pub/data/normals/1981-2010/readme.txt
process_noaa_normals_data <- function(data){
  # convert data format for all months
  data[,2:13] <- lapply(data[,2:13], strip_flag_convert_to_deg)
  data
}

# strip flag (ignore) and convert to degrees
strip_flag_convert_to_deg <- function(data){
  as.double(substr(data, 1, nchar(data) - 1))/10
}
