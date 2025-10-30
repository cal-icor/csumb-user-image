#!/usr/bin/env Rscript

r = getOption("repos")
r["CRAN"] = "https://packagemanager.posit.co/cran/__linux__/noble/2025-10-23"
options(repos = r)

# Function to install R packages
install_packages_with_versions <- function(packages) {
  available <- available.packages()
  to_install <- names(packages)[!(names(packages) %in% rownames(installed.packages()))]

  if (length(to_install) > 0) {
    install.packages(to_install, available = available,
                     versions = packages[to_install],
                     dependencies = TRUE,
                     lib = Sys.getenv("R_LIBS_USER"))
  } else {
    cat("All packages are already installed.\n")
  }
}

# List of packages to ensure are installed
required_packages <- c("renv", "remotes", "devtools")

# Check and install required packages
new_packages <- required_packages[!sapply(required_packages, requireNamespace, quietly = TRUE)]
if (length(new_packages) > 0) {
  install.packages(new_packages, lib = Sys.getenv("R_LIBS_USER"))
}

packages = list(
  "GGally" = "2.4.0", # https://github.com/cal-icor/csumb-user-image/issues/25
  "IRkernel" = "1.3.2", # required for jupyter R kernel
  "Lock5Data" = "3.0.0", # https://github.com/cal-icor/cal-icor-hubs/issues/163
  "RColorBrewer" = "1.1-3", # https://github.com/cal-icor/csumb-user-image/issues/1
  "car" = "3.1-3", # https://github.com/cal-icor/cal-icor-hubs/issues/163
  "colorspace" = "2.1-2", # https://github.com/cal-icor/csumb-user-image/issues/1
  "esquisse" = "2.1.0", # https://github.com/cal-icor/cal-icor-hubs/issues/294
  "extrafont" = "0.20", # https://github.com/cal-icor/csumb-user-image/issues/25
  "flexdashboard" = "0.6.2", # https://github.com/cal-icor/csumb-user-image/issues/25
  "forcats" = "1.0.0", # https://github.com/cal-icor/cal-icor-hubs/issues/294
  "forecast" = "8.24.0", # https://github.com/cal-icor/csumb-user-image/issues/25
  "gdalcubes" = "0.7.0",
  "ggThemeAssist" = "0.1.5", # https://github.com/cal-icor/cal-icor-hubs/issues/294
  "ggalluvial" = "0.12.5", # https://github.com/cal-icor/csumb-user-image/issues/1
  "ggbeeswarm" = "0.7.2", # https://github.com/cal-icor/csumb-user-image/issues/25
  "ggcorrplot" = "0.1.4.1", # https://github.com/cal-icor/csumb-user-image/issues/25
  "ggdist" = "3.3.3", # https://github.com/cal-icor/csumb-user-image/issues/25
  "ggformula" = "0.12.0", # https://github.com/cal-icor/cal-icor-hubs/issues/163
  "gghighlight" = "0.5.0", # https://github.com/cal-icor/csumb-user-image/issues/25
  "ggmosaic" = "0.3.3", # https://github.com/cal-icor/csumb-user-image/issues/1
  "ggrepel" = "0.9.6", # https://github.com/cal-icor/csumb-user-image/issues/1
  "ggridges" = "0.5.7", # https://github.com/cal-icor/csumb-user-image/issues/25
  "ggtext" = "0.1.2", # https://github.com/cal-icor/csumb-user-image/issues/25
  "ggThemeAssist" = "0.1.5", # https://github.com/cal-icor/cal-icor-hubs/issues/294
  "ggthemes" = "5.1.0", # https://github.com/cal-icor/csumb-user-image/issues/1
  "gridExtra" = "2.3", # https://github.com/cal-icor/csumb-user-image/issues/25
  "janitor" = "2.2.1", # https://github.com/cal-icor/csumb-user-image/issues/1
  "knitr" = "1.50", # https://github.com/cal-icor/cal-icor-hubs/issues/163
  "leaflet" = "2.2.3", # https://github.com/cal-icor/csumb-user-image/issues/25
  "lubridate" = "1.9.4", # https://github.com/cal-icor/cal-icor-hubs/issues/294
  "magick" = "2.9.0", # https://github.com/cal-icor/csumb-user-image/issues/25
  "mapgl" = "0.4.1",
  "mapproj" = "1.2.12", # https://github.com/cal-icor/csumb-user-image/issues/25
  "maps" = "3.4.3", # https://github.com/cal-icor/csumb-user-image/issues/25
  "minioclient" = "0.0.6",
  "mosaic" = "1.9.1", # https://github.com/cal-icor/cal-icor-hubs/issues/163
  "naniar" = "1.1.0", # https://github.com/cal-icor/csumb-user-image/issues/1
  "openintro" = "2.5.0", # https://github.com/cal-icor/csumb-user-image/issues/1
  "palmerpenguins" = "0.1.1", # https://github.com/cal-icor/csumb-user-image/issues/25
  "pbdZMQ" = "0.3-14", # required for jupyter R kernel
  "plotly" = "4.11.0", # https://github.com/cal-icor/csumb-user-image/issues/25
  "pwr" = "1.3-0", # https://github.com/cal-icor/cal-icor-hubs/issues/163
  "reticulate" = "1.43.0",
  "rmarkdown" = "2.29", # https://github.com/cal-icor/cal-icor-hubs/issues/163
  "rstac" = "1.0.1",
  "scales" = "1.4.0", # https://github.com/cal-icor/csumb-user-image/issues/25
  "see" = "0.12.0", # https://github.com/cal-icor/csumb-user-image/issues/1
  "sf" = "1.0-19",
  "socviz" = "1.2", # https://github.com/cal-icor/csumb-user-image/issues/25
  "stars" = "0.6-7",
  "sweep" = "0.2.6", # https://github.com/cal-icor/csumb-user-image/issues/25
  "terra" = "1.8-10",
  "tidymodels" = "1.3.0", # https://github.com/cal-icor/cal-icor-hubs/issues/163
  "tidyquant" = "1.0.11", # https://github.com/cal-icor/csumb-user-image/issues/25
  "tidyr" = "1.3.1", # https://github.com/cal-icor/cal-icor-hubs/issues/294
  "tidyverse" = "2.0.0",
  "timetk" = "2.9.1", # https://github.com/cal-icor/csumb-user-image/issues/25
  "viridis" = "0.6.5" # https://github.com/cal-icor/csumb-user-image/issues/1

  # Ensure that every entry have a comma, except the last one.
)

install_packages_with_versions(packages)

# install GitHub packages
remotes::install_github("hrbrmstr/waffle", lib = "/srv/r") # https://github.com/cal-icor/cal-icor-hubs/issues/294
#IRkernel::installspec(user = FALSE, prefix='/srv/conda')
#IRkernel::installspec(user = FALSE, prefix=Sys.getenv("CONDA_DIR"))
