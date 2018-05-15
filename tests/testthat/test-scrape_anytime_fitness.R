# Unit tests for scrape_anytime_fitness

context("scrape_anytime_fitness")

test_that("generate_url invalid state abbreviations", {
  expect_error(generate_url("NY"), "Invalid state abbreviation", fixed = TRUE)
  expect_error(generate_url("wyoming"),
               "Invalid state abbreviation", fixed = TRUE)
  expect_error(generate_url("Ca"), "Invalid state abbreviation", fixed = TRUE)
  expect_error(generate_url("w a"), "Invalid state abbreviation", fixed = TRUE)
})

test_that("generate_url correct abbreviations", {
  expect_equal(generate_url("fl"),
               "http://www.anytimefitness.com/locations/us/fl")
  expect_equal(generate_url("ak"),
               "http://www.anytimefitness.com/locations/us/ak")
})

# website seems to block requests that are repeated so this test will not
# be enabled unless needed for debugging
test_that("scrape_url got data", {
  skip("only enabled for debugging purposes")
  expect(length(scrape_url(generate_url("id"))) > 0)
})

# bad url
test_that("scrape_url bad url", {
  expect_error(scrape_url("http://kjasnqerin23rkn3rvsdn.qwe"))
})

# process data
# make sure to set the google_api_key variable to your Google API key
test_that("process_data good data good", {
  input_data <- c("Cody, WY", "534 Yellowstone Ave", "(307) 578-8550", "Open",
                  "Lander, WY", "943 Amoretti St", "(307) 332-2811", "Open" )
  lat <- c(44.51648, 42.83884)
  lon <- c(-109.0824, -108.7432)
  title <- c("Anytime Fitness [Open]: 534 Yellowstone Ave, Cody, WY",
             "Anytime Fitness [Open]: 943 Amoretti St, Lander, WY")
  url <- c("http://www.anytimefitness.com/locations/us/wy",
           "http://www.anytimefitness.com/locations/us/wy")
  expected_out <- data.frame(lon, lat, title, url, stringsAsFactors = FALSE)

  out <- process_data("http://www.anytimefitness.com/locations/us/wy",
                      input_data,
                      google_api_key)

  expect_true(all.equal(expected_out, out, tolerance = 0.001))
})
