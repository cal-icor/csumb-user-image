#!/usr/bin/env Rscript

# Function to install R packages
install_packages_with_versions <- function(packages) {
  available <- available.packages()
  to_install <- names(packages)[!(names(packages) %in% rownames(installed.packages()))]

  if (length(to_install) > 0) {
    install.packages(to_install, available = available,
                     versions = packages[to_install],
                     dependencies = TRUE)
  } else {
    cat("All packages are already installed.\n")
  }
}

# List of packages to ensure are installed
required_packages <- c("remotes", "devtools")

# Check and install required packages
new_packages <- required_packages[!sapply(required_packages, requireNamespace, quietly = TRUE)]
if (length(new_packages) > 0) {
  install.packages(new_packages)
}

packages = list(
  "IRkernel" = "1.3.2", # required for jupyter R kernel
  "car" = "3.1-3", # https://github.com/cal-icor/cal-icor-hubs/issues/163
  "esquisse" = "2.1.0", # https://github.com/cal-icor/cal-icor-hubs/issues/294
  "forcats" = "1.0.0", # https://github.com/cal-icor/cal-icor-hubs/issues/294
  "gdalcubes" = "0.7.0",
  "ggformula" = "0.12.0", # https://github.com/cal-icor/cal-icor-hubs/issues/163
  "ggThemeAssist" = "0.1.5", # https://github.com/cal-icor/cal-icor-hubs/issues/294
  "knitr" = "1.50", # https://github.com/cal-icor/cal-icor-hubs/issues/163
  "Lock5Data" = "3.0.0", # https://github.com/cal-icor/cal-icor-hubs/issues/163
  "lubridate" = "1.9.4", # https://github.com/cal-icor/cal-icor-hubs/issues/294
  "mapgl" = "0.2.0",
  "minioclient" = "0.0.6",
  "mosaic" = "1.9.1", # https://github.com/cal-icor/cal-icor-hubs/issues/163
  "pwr" = "1.3-0", # https://github.com/cal-icor/cal-icor-hubs/issues/163
  "rmarkdown" = "2.29", # https://github.com/cal-icor/cal-icor-hubs/issues/163
  "rstac" = "1.0.1",
  "sf" = "1.0-19",
  "stars" = "0.6-7",
  "terra" = "1.8-10",
  "tidymodels" = "1.3.0", # https://github.com/cal-icor/cal-icor-hubs/issues/163
  "tidyr" = "1.3.1", # https://github.com/cal-icor/cal-icor-hubs/issues/294
  "tidyverse" = "2.0.0"

  # Ensure that every entry have a comma, except the last one.
)

install_packages_with_versions(packages)

# install GitHub packages
remotes::install_github("hrbrmstr/waffle") # https://github.com/cal-icor/cal-icor-hubs/issues/294
