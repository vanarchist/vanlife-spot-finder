# Vanlife Spot Finder

![Screenshot](https://steemitimages.com/DQmbGxCiQ2kgvwBeFdMu3zCygfSdzoNUPGRBYpqWWCtJf1U/spot_finder_demo_crop.png)

Vanlife Spot Finder is designed to help people living in vehicles find good free spots to camp. Currently, it is focused on the United States but could eventually support other countries.

The latest version is live at https://vanarchist.shinyapps.io/vanlife-spot-finder/

## Roadmap

A growing list of development task requests is being generated. These task requests define planned features of the Vanlife Spot Finder. If you would like to contribute, join [Steemit](https://www.steemit.com) and [Utopian](https://utopian.io) and you can be compensated for your work.

Development Task Requests:

[Land Boundary Mode Task Request](https://steemit.com/utopian-io/@vanarchist/vanlife-spot-finder-land-boundary-mode-task-request)

[Weather Overlay Task Request](https://steemit.com/utopian-io/@vanarchist/vanlife-spot-finder-weather-overlay-task-request)

## Submission Requirements

### Static Analysis
If adding or changing an R source file, run lintr on it and ensure there are no violations. You will need to install lintr, see [this page](https://github.com/jimhester/lintr) for instructions. This will ensure a consistent coding standard across the application. Lintr can be run against a source file with the following command:

```
lintr::lint("file.R")
```
Note that static analysis is run as part of the test suite in the following section so it doesn't have to be performed manually.

### Unit Tests
If adding or changing an R source file, modify or add unit tests as appropriate and ensure that all tests pass prior to submission. You will need to install testthat, see [this page](https://github.com/r-lib/testthat) for instructions. The testthat unit tests can be run with the following command from the project root directory:

```
devtools::test()

```
