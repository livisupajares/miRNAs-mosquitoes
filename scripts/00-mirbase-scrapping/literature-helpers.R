# ~~~~~ HELPERS FOR TURNING PAPER FINDINGS INTO TABLE S1 ROWS ~~~~~
# Sourced by 06-build-s1-literature-tab.R and 07-build-literature-s1-combined.R.
# Expects in_dir to be set and mirbase-helpers.R to be sourced.
library(dplyr)
library(stringr)
library(readxl)

# ==== Table S1 templates (one DENV row per study) ====
read_sheet <- function(sheet) {
  read_excel(file.path(in_dir, "table-s1.xlsx"), sheet = sheet,
             col_types = "text", na = c("", "NA"))
}
aae <- read_sheet("Aedes aegypti")
aal <- read_sheet("Aedes albopictus")
removed <- read_sheet("Removed studies")
templates <- bind_rows(aae, aal, select(removed, -removal_reason)) |>
  filter(infection == "denv") |>
  group_by(citation_exp) |>
  slice(1) |>
  ungroup() |>
  # readxl gives whole numbers as "2.0"; S1 shows them as "2"
  mutate(across(everything(), ~ str_replace(.x, "^(-?[0-9]+)\\.0$", "\\1")))

# ==== v23 precursors, for pre_seq of aae rows ====
pre <- read.csv(file.path(in_dir, "aae-v23.csv"), na.strings = c("", "NA")) |>
  select(pre_mirna_name, pre_seq, mat_acc_mirb1, mat_acc_mirb2)
pre_for_acc <- function(acc) {
  vapply(acc, function(a) {
    if (is.na(a)) return(NA_character_)
    a <- str_split_i(a, " \\| ", 1)
    hit <- pre$pre_seq[pre$mat_acc_mirb1 %in% a | pre$mat_acc_mirb2 %in% a]
    if (length(hit) == 0) NA_character_ else str_trim(hit[1])
  }, character(1), USE.NAMES = FALSE)
}

# miRNAs each paper says it confirmed by (stem-loop) RT-qPCR (main text)
validated <- list(
  "Su et al., 2017" = c("miR-1767", "miR-276-3p", "miR-4448", "miR-4728-5p"),
  "Su et al., 2019" = c("miR-1767", "miR-276-3p", "miR-4448", "miR-622"),
  "Liu et al., 2015" = c("miR-10", "miR-1890", "miR-263a-5p", "miR-263b-5p",
                         "miR-281-5p", "let-7")
)

# Short v23 name without the species prefix, and whether the sequence is
# miRBase's own (aae exact match), which is then written "start - SEQ - end".
add_row_keys <- function(lit) {
  lit |>
    mutate(
      species_full = if_else(species == "aae", "Aedes aegypti", "Aedes albopictus"),
      v23_short = str_remove_all(str_split_i(v23_name, " \\| ", 1), "^aae-"),
      is_mirbase_seq = species == "aae" & v23_match %in% "exact"
    )
}

# One Table S1 row per finding. Study-level columns are copied from an existing
# S1 row of the same study, then overwritten where this finding differs.
build_s1_rows <- function(cand) lapply(seq_len(nrow(cand)), function(i) {
  x <- cand[i, ]
  t <- templates |> filter(citation_exp == x$study)
  stopifnot(nrow(t) == 1)
  cell <- str_detect(x$system, "C6|cells")
  midgut <- str_detect(x$system, "midgut")
  loc <- case_when(cell ~ "cells", midgut ~ "midgut", TRUE ~ "whole-body")
  val <- if (x$study %in% names(validated)) {
    if (str_remove(x$mirna_reported, "\\*$") %in% validated[[x$study]])
      paste0(x$direction, "-regulated") else "not selected"
  } else if (x$study == "Yan et al., 2014") {
    paste0(x$direction, "-regulated")  # the RT-qPCR is the measurement itself
  } else t$exp_DENV_validated
  t |>
    mutate(
      acc_mirb = if (x$species == "aae" && !is.na(x$v23_acc)) str_split_i(x$v23_acc, " \\| ", 1) else NA_character_,
      mirna_name = coalesce(x$v23_short, str_replace(x$mirna_reported, "^mir-", "miR-") |>
                              str_remove("^aal-")),
      pre_seq = if (x$species == "aae") pre_for_acc(x$v23_acc) else NA_character_,
      mat_seq = case_when(
        x$is_mirbase_seq ~ x$v23_seq_pos,
        TRUE ~ x$seq_reported
      ),
      species = x$species_full,
      location = loc,
      DENV_location = loc,
      exp_DENV = if (x$direction %in% c("up", "down")) paste0(x$direction, "-regulated") else x$direction,
      exp_denv_value = x$logFC,
      exp_DENV_validated = val,
      # Yan 2014 adult females: different experiment from the C6/36 template row
      sex = if (!cell && x$study == "Yan et al., 2014") "female" else sex,
      stage = if (!cell && x$study == "Yan et al., 2014") "adult" else stage,
      cell_line_denv = if (cell) cell_line_denv else "NA",
      exp_metric_denv = if (!cell && x$study == "Yan et al., 2014")
        "miRNAs relative expression by RT-qPCR at 7 dpi, p < 0.05 (Fig 2 asterisks)" else exp_metric_denv,
      DENV_exp_conditions = if (!cell && x$study == "Yan et al., 2014")
        "12 miRNAs expression levels were also analyzed in female Ae. albopictus 7 days after DENV-2 inoculation by RT-qPCR (Yan et al., 2014, p.4)." else DENV_exp_conditions,
      DENV_pbm_time_d = if (x$study == "Su et al., 2019") "NA" else DENV_pbm_time_d,
      curation_status = x$curation_status,
      mirna_name_paper = x$mirna_reported,
      v23_match = x$v23_match,
      v23_relation = x$v23_relation,
      seq_source = x$seq_source,
      evidence_locator = paste(x$comparison, x$locator, sep = "; "),
      new_v23_arms_at_locus = x$new_arms
    )
})


# Same column order as the "Aedes aegypti" sheet (the albopictus sheet is the
# same minus exp_ZIKA / ZIKA_location).
s1_cols <- names(aae)
