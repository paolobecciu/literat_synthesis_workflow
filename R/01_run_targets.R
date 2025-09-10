
# scripts/01_run_targets.R
pkgs <- c("targets","tarchetypes","tidyverse","readxl","janitor","stringr","lubridate",
          "yaml","quanteda","ggplot2","PRISMA2020","htmlwidgets")
to_install <- setdiff(pkgs, rownames(installed.packages()))
if (length(to_install)) install.packages(to_install, dependencies = TRUE)

targets::tar_make()
