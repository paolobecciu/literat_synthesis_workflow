
# R/tagging.R 
# dictionary-based category tagging; fully transparent & editable

library(quanteda)
library(yaml)

tag_categories <- function(df, dict_path = "config/categories.yml") {
  dict <- yaml::read_yaml(dict_path)
  
  # combine text fields for tagging
  txt <- paste(df$title, df$abstract, df$keywords, sep = " ")
  corp <- quanteda::corpus(txt)
  toks <- quanteda::tokens(
    corp, remove_punct = TRUE, remove_numbers = TRUE
  )
  toks <- quanteda::tokens_tolower(toks)
  
  qdict <- quanteda::dictionary(dict)
  m <- quanteda::dfm(toks) |> quanteda::dfm_lookup(qdict, exclusive = FALSE)
  tags <- as.data.frame(quanteda::convert(m, to = "data.frame"))
  tags <- dplyr::select(tags, -document)
  names(tags) <- paste0("cat_", names(tags))
  
  dplyr::bind_cols(df, tags)
}

write_tagged <- function(df, out_path = "data/processed/validated_with_tags.csv") {
  dir.create(dirname(out_path), recursive = TRUE, showWarnings = FALSE)
  readr::write_csv(df, out_path, na = "")
  out_path
}
