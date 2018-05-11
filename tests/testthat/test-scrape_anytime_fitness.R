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
