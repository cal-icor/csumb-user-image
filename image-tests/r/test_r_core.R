#!/usr/bin/env Rscript

# Verify R is the system R, not a conda-installed R.
# Conda packages like sagemath pull in r-base via rpy2, which shadows
# /usr/bin/R on PATH and causes version mismatches and broken rsession startup.
r_home <- R.home()
if (grepl("conda", r_home, fixed = TRUE)) {
    stop(paste("R is running from conda, not the system installation:", r_home))
}

# Verify the pinned R version matches what is in the image spec.
expected_version <- "4.5.1"
actual_version <- paste(R.version$major, R.version$minor, sep = ".")
if (!startsWith(actual_version, expected_version)) {
    stop(paste("R version mismatch. Expected:", expected_version, "Got:", actual_version))
}

# IRkernel must be installed for the Jupyter R kernel to work.
if (!requireNamespace("IRkernel", quietly = TRUE)) {
    stop("IRkernel is not installed")
}

packages <- c(
    "GGally",
    "Lock5Data",
    "RColorBrewer",
    "car",
    "colorspace",
    "esquisse",
    "extrafont",
    "flexdashboard",
    "forcats",
    "forecast",
    "ggThemeAssist",
    "ggalluvial",
    "ggbeeswarm",
    "ggcorrplot",
    "ggdist",
    "ggformula",
    "gghighlight",
    "ggmosaic",
    "ggpubr",
    "ggrepel",
    "ggridges",
    "ggtext",
    "ggthemes",
    "gridExtra",
    "gtsummary",
    "janitor",
    "knitr",
    "leaflet",
    "lubridate",
    "mosaic",
    "naniar",
    "nycflights13",
    "openintro",
    "palmerpenguins",
    "plotly",
    "pwr",
    "rmarkdown",
    "scales",
    "see",
    "sf",
    "sjPlot",
    "socviz",
    "terra",
    "tidymodels",
    "tidyr",
    "tidyverse",
    "viridis"
)

for (pkg in packages) {
    if (!requireNamespace(pkg, quietly = TRUE)) {
        stop(paste("Package not available:", pkg))
    }
    suppressPackageStartupMessages(library(pkg, character.only = TRUE))
}

# Basic computation: linear model on a built-in dataset.
data("penguins", package = "palmerpenguins")
m <- lm(bill_length_mm ~ flipper_length_mm, data = penguins, na.action = na.omit)
if (length(coef(m)) != 2) {
    stop("lm() returned unexpected number of coefficients")
}
if (any(is.na(coef(m)))) {
    stop("lm() coefficients contain NA")
}

cat("R core tests passed\n")
