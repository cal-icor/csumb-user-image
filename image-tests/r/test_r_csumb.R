#!/usr/bin/env Rscript

# CSUMB-specific R packages not present in base-user-image.
packages <- c(
    "BSDA",
    "DescTools",
    "reticulate",
    "pbdZMQ",
    "sweep",
    "tidyquant",
    "tidyverse",
    "timetk"
)

for (pkg in packages) {
    if (!requireNamespace(pkg, quietly = TRUE)) {
        stop(paste("Package not available:", pkg))
    }
    suppressPackageStartupMessages(library(pkg, character.only = TRUE))
}

cat("R CSUMB-specific tests passed\n")
