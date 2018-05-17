context("test-scrape_freecampsites.R")

test_that("freecampsites_generate_url invalid state name", {
  expect_error(freecampsites_generate_url("NY"), "Invalid state name",
               fixed = TRUE)
  expect_error(freecampsites_generate_url("wyoming"),
               "Invalid state name", fixed = TRUE)
  expect_error(freecampsites_generate_url("CALIFORNIA"), "Invalid state name",
               fixed = TRUE)
  expect_error(freecampsites_generate_url("New york"), "Invalid state name",
               fixed = TRUE)
})

test_that("freecampsites_generate_url correct state name", {
  expect_equal(freecampsites_generate_url("Florida"),
               paste0("https://freecampsites.net/wp-content/themes/",
                      "freecampsites/androidApp.php?region=Florida&",
                      "advancedSearch={}"))
})
