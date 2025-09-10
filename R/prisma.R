
# R/prisma.R
# PRISMA-2020 flow diagram scaffolding
# Create/consume data/interim/prisma_counts.csv with columns:
# database_results, duplicates_removed, records_screened, records_excluded,
# full_text_assessed, full_text_excluded, studies_included

build_prisma <- function(counts_csv = "data/interim/prisma_counts.csv",
                         out = "outputs/figures/prisma.html") {
  if (!file.exists(counts_csv)) {
    tmpl <- tibble::tibble(
      data = c("database_results","duplicates_removed","records_screened","records_excluded",
               "full_text_assessed","full_text_excluded","studies_included"),
      n = c(0,0,0,0,0,0,0)
    )
    dir.create(dirname(counts_csv), recursive = TRUE, showWarnings = FALSE)
    readr::write_csv(tmpl, counts_csv)
    message("Template counts written to ", counts_csv)
  }
  counts <- readr::read_csv(counts_csv, show_col_types = FALSE)
  d <- stats::setNames(as.list(counts$n), counts$data)
  
  g <- PRISMA2020::PRISMA_flowdiagram(
    prisma = list(
      database_results  = d$database_results,
      duplicates_removed= d$duplicates_removed,
      records_screened  = d$records_screened,
      records_excluded  = d$records_excluded,
      full_text_assessed= d$full_text_assessed,
      full_text_excluded= d$full_text_excluded,
      studies_included  = d$studies_included
    ),
    interactive = TRUE
  )
  htmlwidgets::saveWidget(g, out, selfcontained = TRUE)
  out
}
