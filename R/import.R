
# R/import.R

list_files_raw <- function(dir = "data/raw") {
  list.files(dir, pattern = "\\.(xls|xlsx)$", full.names = TRUE)
}

# Read a single WoS Excel file (binds all sheets)
read_wos_excel <- function(path) {
  sh <- readxl::excel_sheets(path)
  purrr::map_dfr(sh, function(s) {
    df <- readxl::read_excel(path, sheet = s)
    df$source_file <- basename(path)
    df$source_sheet <- s
    df
  })
}

# Read many files
read_wos_files <- function(paths) {
  purrr::map_dfr(paths, read_wos_excel)
}

# Harmonize to a minimal, robust schema (keep everything else too)
harmonize_fields <- function(df) {
  df %>%
    janitor::clean_names() %>%
    dplyr::mutate(
      title   = dplyr::coalesce(.data$title, .data$ti, .data$article_title),
      abstract= dplyr::coalesce(.data$abstract, .data$ab),
      doi     = dplyr::coalesce(.data$doi, .data$di),
      year    = suppressWarnings(as.integer(dplyr::coalesce(as.character(.data$py), as.character(.data$year)))),
      authors = dplyr::coalesce(.data$au, .data$authors),
      journal = dplyr::coalesce(.data$so, .data$source_title, .data$journal),
      # combine author + keyword lists if present
      keywords = dplyr::case_when(
        !is.na(.data$de) & !is.na(.data$id) ~ paste0(.data$de, "; ", .data$id),
        !is.na(.data$de) ~ .data$de,
        !is.na(.data$id) ~ .data$id,
        TRUE ~ NA_character_
      )
    ) %>%
    dplyr::mutate(
      title_norm = stringr::str_squish(stringr::str_to_lower(title)),
      doi        = stringr::str_to_lower(doi)
    )
}

# Infer A/B + index from filenames like A1_papersWoS.xls, A2_p1, B3, etc.
attach_search_group <- function(df) {
  df %>%
    dplyr::mutate(
      search_group = stringr::str_extract(.data$source_file, "^[A-B][0-9]+"),
      search_group = dplyr::coalesce(search_group, "unknown")
    )
}

# Build the screening queue used by metagear/revtools
build_screening_queue <- function(df, out_path = "data/interim/screen_queue.csv") {
  out <- df %>%
    dplyr::transmute(
      RECORD_ID = dplyr::row_number(),
      TITLE = title,
      ABSTRACT = abstract,
      YEAR = year,
      DOI = doi,
      JOURNAL = journal,
      KEYWORDS = keywords,
      SEARCH_GROUP = search_group,
      SOURCE_FILE = source_file,
      SOURCE_SHEET = source_sheet,
      dup_by_doi = dplyr::if_else(is.na(doi), FALSE, FALSE), # keeps column present before flagging step
      dup_by_title_year = FALSE,                             # ditto
      INCLUDE = NA_character_,   # to be filled by screeners (yes/no/maybe)
      EXCLUDE_REASON = NA_character_
    )
  dir.create(dirname(out_path), recursive = TRUE, showWarnings = FALSE)
  readr::write_csv(out, out_path, na = "")
  out_path
}
