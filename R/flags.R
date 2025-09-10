
# R/flags.R
# flag duplicates—do not remove

flag_duplicates <- function(df) {
  df %>%
    dplyr::group_by(doi) %>%
    dplyr::mutate(dup_by_doi = dplyr::n() > 1 & !is.na(doi)) %>%
    dplyr::ungroup() %>%
    dplyr::group_by(title_norm, year) %>%
    dplyr::mutate(dup_by_title_year = dplyr::n() > 1 & !is.na(title_norm) & !is.na(year)) %>%
    dplyr::ungroup()
}
