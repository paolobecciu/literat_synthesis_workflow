
# R/plots.R
# timelines: per search group; stacked by category

plot_timeline <- function(df, out_dir = "outputs/figures") {
  dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
  p <- df %>%
    dplyr::filter(!is.na(year)) %>%
    dplyr::count(year, search_group, name = "n") %>%
    ggplot2::ggplot(ggplot2::aes(year, n)) +
    ggplot2::geom_col() +
    ggplot2::facet_wrap(~ search_group, scales = "free_y") +
    ggplot2::labs(x = NULL, y = "Papers per year", title = "WoS papers per year by search group") +
    ggplot2::theme_minimal()
  file <- file.path(out_dir, "timeline_by_group.png")
  ggplot2::ggsave(file, p, width = 10, height = 6, dpi = 300)
  file
}

plot_timeline_by_category <- function(df, out_dir = "outputs/figures") {
  dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
  cat_cols <- names(df)[grepl("^cat_", names(df))]
  if (!length(cat_cols)) {
    # create a marker file to indicate skip
    file <- file.path(out_dir, "timeline_by_category_SKIPPED.txt")
    writeLines("No category columns found. Did tagging run?", file)
    return(file)
  }
  long <- df %>%
    dplyr::select(year, search_group, dplyr::all_of(cat_cols)) %>%
    tidyr::pivot_longer(dplyr::all_of(cat_cols), names_to = "category", values_to = "hits") %>%
    dplyr::mutate(hits = as.integer(hits > 0)) %>%
    dplyr::group_by(year, search_group, category) %>%
    dplyr::summarise(n = sum(hits, na.rm = TRUE), .groups = "drop")
  
  p <- ggplot2::ggplot(long, ggplot2::aes(year, n, fill = category)) +
    ggplot2::geom_col() +
    ggplot2::facet_wrap(~ search_group, scales = "free_y") +
    ggplot2::labs(x = NULL, y = "Tagged papers per year", title = "WoS papers per year by category") +
    ggplot2::theme_minimal()
  file <- file.path(out_dir, "timeline_by_category.png")
  ggplot2::ggsave(file, p, width = 12, height = 7, dpi = 300)
  file
}
