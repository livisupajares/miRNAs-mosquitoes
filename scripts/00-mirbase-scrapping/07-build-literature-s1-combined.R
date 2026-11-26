# ~~~~~ ONE TABLE: EVERY FINDING, IN TABLE S1 COLUMNS, WITH ITS EVIDENCE ~~~~~
# Joins three things into a single CSV, one row per study x miRNA x condition:
#   1. every finding extracted from the papers (output of script 05), for
#      all four infections in Table S1: denv, zika, chikv and wolbachia,
#   2. all Table S1 columns filled in (same rules as script 06: miRBase v23.1
#      name, sequence as the paper reported it, "start - SEQ - end" when the
#      sequence is miRBase's own, NA when unknown),
#   3. the study-level evidence: finding, exact quotation, locator, source
#      coverage and support (databases/00-mirbase-scrapping/literature/
#      study-evidence.tsv, written by hand from the PDFs).
# Papers that were read but set aside (wrong serotype, no DE, etc.) get one row
# each with the S1 columns as NA, so the reason stays visible.
#
# Status column (s1_status):
#   IN S1                 already in Table S1 for this study
#   ONLY IN REMOVED       only on the "Removed studies" sheet
#   ADD                   missing from S1 and significant in the paper
#   CHECK: ...            S1 has a close name; a human must decide
#   EXCLUDED: ...         missing from S1 but not significant in the paper
#   STUDY SET ASIDE       paper read, no usable DE finding
#
# Table S1 itself is not modified.
#
# Run from the project root (after 05-):
#   Rscript scripts/00-mirbase-scrapping/07-build-literature-s1-combined.R

library(dplyr)
library(stringr)
library(readxl)
source("scripts/00-mirbase-scrapping/mirbase-helpers.R")

in_dir <- "databases/00-mirbase-scrapping"
lit_dir <- file.path(in_dir, "literature")
out_dir <- "results/00-mirbase-v23"
source("scripts/00-mirbase-scrapping/literature-helpers.R")

lit <- read.csv(file.path(out_dir, "literature-all-vs-v23-vs-s1.csv"),
                na.strings = c("", "NA"))
evidence <- read.delim(file.path(lit_dir, "study-evidence.tsv"),
                       quote = "", na.strings = c("", "NA"), check.names = FALSE)

# ==== Status of every finding against Table S1 ====
findings <- lit |>
  mutate(
    p_num = suppressWarnings(as.numeric(p)),
    s1_status = case_when(
      in_s1 == "yes" ~ "IN S1",
      in_s1 == "only in Removed studies" ~ "ONLY IN REMOVED",
      !is.na(p_num) & p_num > 0.05 ~ "EXCLUDED: not significant (p > 0.05)",
      str_starts(in_s1, "yes, but") ~ paste0("CHECK: S1 already has ", s1_names),
      TRUE ~ "ADD"
    ),
    curation_status = s1_status,
    # Where the sequence in mat_seq comes from, in the same vocabulary as the
    # source coverage column.
    sequence_coverage = case_when(
      is.na(seq_reported) ~ "unavailable",
      str_detect(seq_source, "GUESS") ~ "guess (another paper's supplement)",
      str_detect(seq_source, "Additional file") ~ "passage retrieved (paper supplement)",
      TRUE ~ "passage retrieved"
    ),
    # Finding-level support: the study supports the call unless the paper's own
    # p value is above 0.05.
    finding_support = if_else(!is.na(p_num) & p_num > 0.05, "uncertain", "supported"),
    v23_new = case_when(
      v23_new %in% TRUE ~ "yes",
      v23_new %in% FALSE ~ "no",
      !is.na(new_arms) & new_arms != "" ~ paste0("possible, arm not given (", new_arms, ")"),
      TRUE ~ "no"
    )
  ) |>
  add_row_keys()

rows <- bind_rows(build_s1_rows(findings)) |>
  select(all_of(s1_cols), mirna_name_paper, v23_match, v23_relation, seq_source,
         evidence_locator, new_v23_arms_at_locus)

combined <- bind_cols(
  rows,
  findings |> select(s1_status, s1_names, v23_new, sequence_coverage, finding_support,
                     direction, logFC, p)
) |>
  left_join(evidence, by = c("citation_exp" = "study"))

# ==== One row per paper that was read but set aside ====
set_aside <- evidence |>
  filter(scope == "set aside") |>
  transmute(citation_exp = study, zotero_key, finding, exact_quote, quote_locator,
            source_coverage, support, scope, coverage_gap,
            s1_status = "STUDY SET ASIDE", finding_support = support)

out <- bind_rows(combined, set_aside) |>
  select(
    all_of(s1_cols),
    s1_status, s1_names, mirna_name_paper, direction, logFC, p,
    v23_match, v23_relation, v23_new, new_v23_arms_at_locus,
    seq_source, sequence_coverage, evidence_locator,
    finding, exact_quote, quote_locator, source_coverage,
    study_support = support, finding_support, scope, coverage_gap, zotero_key
  ) |>
  mutate(across(everything(), ~ coalesce(as.character(.x), "NA"))) |>
  mutate(status_rank = case_when(
    s1_status == "ADD" ~ 1, str_starts(s1_status, "CHECK") ~ 2,
    str_starts(s1_status, "EXCLUDED") ~ 3, s1_status == "ONLY IN REMOVED" ~ 4,
    s1_status == "IN S1" ~ 5, TRUE ~ 6)) |>
  arrange(scope != "included", infection, species, citation_exp, status_rank,
          mirna_name) |>
  select(-status_rank)

write.csv(out, file.path(out_dir, "literature-s1-combined.csv"), row.names = FALSE)

# ==== Console summary (the numbers used in the chat summary) ====
inc <- out |> filter(scope == "included")
cat("Rows:", nrow(out), " findings:", nrow(inc), " set-aside papers:", nrow(set_aside), "\n")
print(count(inc, infection, status = str_extract(s1_status, "^[A-Z ]+"), direction))
print(count(inc, infection, sequence_coverage))
print(count(inc, v23_new = str_extract(v23_new, "^[a-z]+")))
