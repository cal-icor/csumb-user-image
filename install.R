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
)

install_packages_with_versions(packages)
