# ~~~~~ HELPER FUNCTIONS FOR miRBase / TABLE S1 COMPARISONS ~~~~~
# Sourced by 02-compare-mirbase-v22-v23.R and 03-reconcile-s1-v23.R
library(dplyr)
library(stringr)
library(tidyr)

# Keep only nucleotides; convert DNA to RNA.
# "48 - UGGAAUG... - 69" -> "UGGAAUG..."; "TGGACG" -> "UGGACG"
clean_seq <- function(x) {
  x <- toupper(as.character(x))
  x <- str_replace_all(x, "T", "U")
  x <- str_remove_all(x, "[^ACGU]")
  if_else(is.na(x) | x == "", NA_character_, x)
}

# "aae-miR-276-3p" -> "miR-276-3p"; "aal-let-7" -> "let-7"
strip_species <- function(x) str_remove(x, "^[a-z]{3}-")
get_arm <- function(x) str_extract(x, "(?<=-)[35]p$")
get_base <- function(x) str_remove(strip_species(x), "-[35]p$")

# Seed = nucleotides 2-8. A change here changes miRanda target predictions.
seed <- function(x) substr(x, 2, 8)

# Describe how sequence b (new) relates to sequence a (old)
seq_relation <- function(a, b) {
  case_when(
    is.na(a) | is.na(b) ~ NA_character_,
    a == b ~ "identical",
    startsWith(b, a) ~ "3' end extended",
    startsWith(a, b) ~ "3' end trimmed",
    str_detect(b, fixed(a)) | str_detect(a, fixed(b)) ~ "5' end changed",
    TRUE ~ "different sequence"
  )
}

# Turn the wide miRBase scrape (one row per precursor, 2 arms) into one row per
# mature product, collapsing precursors that share the same accession+sequence.
mirbase_long <- function(path) {
  read.csv(path, na.strings = c("", "NA")) |>
    select(
      pre_name = pre_mirna_name, pre_acc = acc_mirb,
      acc_1 = mat_acc_mirb1, name_1 = mat_name_1, seq_1 = mat_seq_1,
      acc_2 = mat_acc_mirb2, name_2 = mat_name_2, seq_2 = mat_seq_2
    ) |>
    pivot_longer(
      cols = acc_1:seq_2,
      names_to = c(".value", "slot"), names_sep = "_"
    ) |>
    filter(!is.na(acc)) |>
    mutate(seq = clean_seq(seq)) |>
    group_by(mat_acc = acc, mat_seq = seq) |>
    summarise(
      mat_name = paste(unique(name), collapse = "; "),
      precursors = paste(unique(pre_name), collapse = "; "),
      .groups = "drop"
    )
}
