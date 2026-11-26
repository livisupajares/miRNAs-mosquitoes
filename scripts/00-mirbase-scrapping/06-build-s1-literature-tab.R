# ~~~~~ DRAFT NEW TABLE S1 TAB: miRNAs MISSING FROM TABLE S1 ~~~~~
# Takes the output of 05-literature-vs-v23.R and drafts rows in exactly the
# Table S1 column layout (see the "metadata" tab), one row per paper miRNA
# that is not yet in Table S1 for that study and infection. Covers all four
# infections in Table S1: denv, zika, chikv and wolbachia; each row fills its
# own infection's columns (exp_CHIKV / exp_ZIKA / exp_wolbachia / exp_DENV).
#
# Rules (Liv, 2026-11-25):
#   * name: miRBase v23.1 name when the paper sequence matches v23
#     (exact or isomiR); otherwise the name the paper used.
#   * sequence: the one the paper reported. When it is identical to the
#     miRBase v23 sequence (aae only) it is written "start - SEQ - end" with
#     positions on the v23 precursor, like the rest of Table S1.
#   * study-level columns (stage, conditions, metric, serotype...) are copied
#     from an existing Table S1 row of the same study, then overwritten where
#     this experiment differs. Anything unknown is "NA".
#   * Table S1 itself is not modified.
#
# Extra review columns are appended AFTER the Table S1 columns:
#   curation_status: ADD (missing, significant), CHECK (S1 has a similar
#   name, a human must decide), EXCLUDED (not significant in the paper).
#
# Run from the project root (after 05-):
#   Rscript scripts/00-mirbase-scrapping/06-build-s1-literature-tab.R

library(dplyr)
library(stringr)
library(readxl)
source("scripts/00-mirbase-scrapping/mirbase-helpers.R")

in_dir <- "databases/00-mirbase-scrapping"
out_dir <- "results/00-mirbase-v23"

lit <- read.csv(file.path(out_dir, "literature-all-vs-v23-vs-s1.csv"),
                na.strings = c("", "NA"))

source("scripts/00-mirbase-scrapping/literature-helpers.R")

cand <- lit |>
  filter(in_s1 != "yes", in_s1 != "only in Removed studies") |>
  mutate(
    p_num = suppressWarnings(as.numeric(p)),
    curation_status = case_when(
      !is.na(p_num) & p_num > 0.05 ~ "EXCLUDED: not significant (p > 0.05)",
      str_starts(in_s1, "yes, but") ~ paste0("CHECK: S1 already has ", s1_names),
      TRUE ~ "ADD"
    )
  ) |>
  add_row_keys()

rows <- build_s1_rows(cand)

# Same column order as the "Aedes aegypti" sheet (the albopictus sheet is the
# same minus exp_ZIKA / ZIKA_location), then the review columns.
review_cols <- c("curation_status", "mirna_name_paper", "v23_match", "v23_relation",
                 "seq_source", "evidence_locator", "new_v23_arms_at_locus",
                 "s1_cell_notes")
tab <- bind_rows(rows) |>
  attach_s1_notes() |>
  select(all_of(s1_cols), all_of(review_cols)) |>
  mutate(across(everything(), ~ coalesce(as.character(.x), "NA"))) |>
  arrange(curation_status != "ADD", infection, species, citation_exp, mirna_name)

write.csv(tab, file.path(out_dir, "s1-new-tab-literature.csv"), row.names = FALSE)
cat("Rows:", nrow(tab), "\n")
print(count(tab, infection, species, citation_exp,
            curation_status = str_sub(curation_status, 1, 8)))
