# ~~~~~ HELPERS FOR TURNING PAPER FINDINGS INTO TABLE S1 ROWS ~~~~~
# Sourced by 06-build-s1-literature-tab.R and 07-build-literature-s1-combined.R.
# Expects in_dir to be set and mirbase-helpers.R to be sourced.
#
# Covers every infection in Table S1: denv, chikv, zika and wolbachia. Each one
# has its own set of S1 columns (see infection_cols below); only DENV has the
# metric/value/validation columns, so for the other three the paper's fold
# change and p value stay in the review columns instead of the S1 columns.
library(dplyr)
library(stringr)
library(readxl)

# ==== Which Table S1 columns belong to which infection ====
# direction: the "exp_*" column holding up-/down-regulated
# location : the per-infection location column
# cell_line: the per-infection cell line column (DENV and some others)
infection_cols <- list(
  denv = list(direction = "exp_DENV", location = "DENV_location",
              cell_line = "cell_line_denv"),
  chikv = list(direction = "exp_CHIKV", location = "CHIKV_location",
               cell_line = "cell_line_chikv"),
  zika = list(direction = "exp_ZIKA", location = "ZIKA_location",
              cell_line = NA_character_),
  wolbachia = list(direction = "exp_wolbachia", location = "wolbachia_location",
                   cell_line = "cell_line_wolbachia")
)

# ==== Table S1 templates (one row per study x infection) ====
read_sheet <- function(sheet) {
  read_excel(file.path(in_dir, "table-s1.xlsx"), sheet = sheet,
             col_types = "text", na = c("", "NA"))
}
aae <- read_sheet("Aedes aegypti")
aal <- read_sheet("Aedes albopictus")
removed <- read_sheet("Removed studies")

# Same column order as the "Aedes aegypti" sheet (the albopictus sheet is the
# same minus exp_ZIKA / ZIKA_location).
s1_cols <- names(aae)

templates <- bind_rows(aae, aal, select(removed, -removal_reason)) |>
  filter(!is.na(infection)) |>
  group_by(citation_exp, infection) |>
  slice(1) |>
  ungroup() |>
  # readxl gives whole numbers as "2.0"; S1 shows them as "2"
  mutate(across(everything(), ~ str_replace(.x, "^(-?[0-9]+)\\.0$", "\\1")))

# An all-NA row in the S1 layout, for a study x infection Table S1 does not
# have yet (e.g. She 2024, Bishop 2022, Zhang 2014).
empty_template <- function(study, infection) {
  t <- as_tibble(setNames(as.list(rep(NA_character_, length(s1_cols))), s1_cols))
  t$citation_exp <- study
  t$infection <- infection
  t
}
template_for <- function(study, infection) {
  t <- templates |> filter(citation_exp == study, infection == !!infection)
  if (nrow(t) == 0) empty_template(study, infection) else t[1, ]
}

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

# miRNAs each paper says it confirmed by (stem-loop) RT-qPCR (main text).
# DENV studies only; the other infections have no such list.
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

# Where in the mosquito the finding was made, from the free-text system column.
location_of <- function(system) {
  case_when(
    str_detect(system, "C6|cells|cell line") ~ "cells",
    str_detect(system, "salivary gland") ~ "salivary gland",
    str_detect(system, "saliva") ~ "saliva",
    str_detect(system, "midgut") ~ "midgut",
    str_detect(system, "fat body") ~ "fat body",
    str_detect(system, "ovar") ~ "ovary",
    TRUE ~ "whole-body"
  )
}

# One Table S1 row per finding. Study-level columns are copied from an existing
# S1 row of the same study and infection, then overwritten where this finding
# differs. Table S1 itself is never modified.
build_s1_rows <- function(cand) lapply(seq_len(nrow(cand)), function(i) {
  x <- cand[i, ]
  t <- template_for(x$study, x$infection)
  cols <- infection_cols[[x$infection]]
  stopifnot(!is.null(cols))
  loc <- location_of(x$system)
  cell <- loc == "cells"
  direction <- if (x$direction %in% c("up", "down"))
    paste0(x$direction, "-regulated") else x$direction

  t$acc_mirb <- if (x$species == "aae" && !is.na(x$v23_acc))
    str_split_i(x$v23_acc, " \\| ", 1) else NA_character_
  t$mirna_name <- coalesce(x$v23_short,
                           str_replace(x$mirna_reported, "^mir-", "miR-") |>
                             str_remove("^aa[el]-"))
  t$pre_seq <- if (x$species == "aae") pre_for_acc(x$v23_acc) else NA_character_
  t$mat_seq <- if (x$is_mirbase_seq) x$v23_seq_pos else x$seq_reported
  t$species <- x$species_full
  t$infection <- x$infection
  t$location <- loc
  t[[cols$direction]] <- direction
  t[[cols$location]] <- loc
  if (!is.na(cols$cell_line) && !cell) t[[cols$cell_line]] <- NA_character_

  if (x$infection == "denv") {
    # DENV is the only infection with metric / value / validation columns.
    t$exp_denv_value <- x$logFC
    t$exp_DENV_validated <- if (x$study %in% names(validated)) {
      if (str_remove(x$mirna_reported, "\\*$") %in% validated[[x$study]])
        direction else "not selected"
    } else if (x$study == "Yan et al., 2014") {
      direction  # the RT-qPCR is the measurement itself
    } else t$exp_DENV_validated
    if (!cell && x$study == "Yan et al., 2014") {
      # Yan 2014 adult females: a different experiment from the C6/36 template
      t$sex <- "female"
      t$stage <- "adult"
      t$exp_metric_denv <-
        "miRNAs relative expression by RT-qPCR at 7 dpi, p < 0.05 (Fig 2 asterisks)"
      t$DENV_exp_conditions <- paste(
        "12 miRNAs expression levels were also analyzed in female Ae. albopictus",
        "7 days after DENV-2 inoculation by RT-qPCR (Yan et al., 2014, p.4).")
    }
    if (x$study == "Su et al., 2019") t$DENV_pbm_time_d <- NA_character_
  }

  t |>
    mutate(
      curation_status = x$curation_status,
      mirna_name_paper = x$mirna_reported,
      v23_match = x$v23_match,
      v23_relation = x$v23_relation,
      seq_source = x$seq_source,
      evidence_locator = paste(x$comparison, x$locator, sep = "; "),
      new_v23_arms_at_locus = x$new_arms
    )
})
