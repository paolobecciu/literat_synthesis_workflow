# _______________________________________________#
## this script orchestrates the whole workflow  ##
#________________________________________________#

# targets gives you a deterministic pipeline; 
# revtools/metagear handle dedup + screening; 
# bibliometrix eats WoS exports; 
# PRISMA2020 produces the flow diagram; 
# quanteda handles dictionary tagging.

# _targets.R
library(targets)
library(tarchetypes)
tar_option_set(packages = c(
  "tidyverse","readxl","janitor","stringr","lubridate",
  "yaml","quanteda","ggplot2","PRISMA2020"
))

source("R/import.R")
source("R/flags.R")
source("R/tagging.R")
source("R/plots.R")
source("R/prisma.R")

list(
  # 1) Locate WoS files (you already placed them under data/raw/)
  tar_target(file_list, list_files_raw("data/raw")),
  
  # 2) Import (+ all sheets) & harmonize; keep duplicates
  tar_target(wos_raw, read_wos_files(file_list)),
  tar_target(harmonized, harmonize_fields(wos_raw)),
  tar_target(with_groups, attach_search_group(harmonized)),
  tar_target(with_flags, flag_duplicates(with_groups)),  # flags only
  
  # 3) Build a screening queue CSV for metagear/revtools
  tar_target(screen_queue, build_screening_queue(with_flags), format = "file"),
  
  # 4) Auto-tag categories (dictionary-driven, editable in config/categories.yml)
  tar_target(with_tags, tag_categories(with_flags, dict_path = "config/categories.yml")),
  tar_target(tagged_csv, write_tagged(with_tags), format = "file"),
  
  # 5) Timelines (counts per year)
  tar_target(fig_timeline_groups, plot_timeline(with_tags, out_dir = "outputs/figures"),
             format = "file"),
  tar_target(fig_timeline_bycat, plot_timeline_by_category(with_tags, out_dir = "outputs/figures"),
             format = "file"),
  
  # 6) PRISMA diagram (fill counts CSV then render)
  tar_target(prisma_html, build_prisma("data/interim/prisma_counts.csv",
                                       out = "outputs/figures/prisma.html"),
             format = "file", cue = tar_cue(mode = "always"))
)
