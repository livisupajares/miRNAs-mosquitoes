# ~~~~~ DIFF CHECKER MIRBASE VERSIONS (NAME LEVEL) ~~~~~~
# Which mature miRNA *names* exist in miRBase v22.1, in v23.1, or in both,
# for Aedes aegypti. Nothing else: Table S1 is deliberately NOT read here, so
# this script can never confuse "absent from Table S1" with "new in miRBase".
#
# This is the name-level view. The two other levels live in their own scripts:
#   02-compare-mirbase-v22-v23.R  accession + sequence level (renamed, sequence
#                                 changed, extra sequence on the same accession,
#                                 new, removed) and the precursors
#   03-reconcile-s1-v23.R         Table S1 (all infections) against v23.1
#
# Inputs : databases/00-mirbase-scrapping/aae-v22.csv, aae-v23.csv (scraped)
# Output : results/00-mirbase-v23/aae-mirbase-v22-vs-v23-names.csv
#
# Run from the project root:
#   Rscript scripts/00-mirbase-scrapping/01-diff-mirbasev22-v23.R

# ==== IMPORT LIBRARIES & HELPERS =====
library(dplyr)
library(stringr)
library(tidyr)
source("scripts/00-mirbase-scrapping/mirbase-helpers.R")

# ==== PATHS ====
in_dir <- "databases/00-mirbase-scrapping"
out_dir <- "results/00-mirbase-v23"
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

# ==== IMPORT DATA ====
# mirbase_long() gives one row per mature product (accession + sequence),
# with both arms of every precursor already unfolded into separate rows.
v22 <- mirbase_long(file.path(in_dir, "aae-v22.csv"))
v23 <- mirbase_long(file.path(in_dir, "aae-v23.csv"))

# ==== ONE ROW PER NAME ====
# A name can carry more than one accession (paralogous loci), so collapse to
# the name and keep the accessions and sequences behind it.
by_name <- function(df, version) {
  df |>
    separate_longer_delim(mat_name, delim = "; ") |>
    mutate(mat_name = str_trim(mat_name)) |>
    group_by(mat_name) |>
    summarise(
      accs = paste(sort(unique(mat_acc)), collapse = "; "),
      seqs = paste(sort(unique(mat_seq)), collapse = "; "),
      n_products = n(),
      .groups = "drop"
    ) |>
    rename_with(~ paste0(.x, "_", version), -mat_name)
}

names_v22 <- by_name(v22, "v22")
names_v23 <- by_name(v23, "v23")

# ==== DIFF ====
diff_names <- full_join(names_v22, names_v23, by = "mat_name") |>
  mutate(
    status = case_when(
      is.na(accs_v22) ~ "name only in v23",
      is.na(accs_v23) ~ "name only in v22",
      seqs_v22 != seqs_v23 ~ "same name, sequence(s) differ",
      accs_v22 != accs_v23 ~ "same name, accession(s) differ",
      TRUE ~ "unchanged"
    ),
    # A name that disappears from v22 and a name that appears in v23 are often
    # the two halves of one rename: flag when the sequence is the same.
    same_seq_elsewhere = case_when(
      status == "name only in v23" ~ seqs_v23 %in% names_v22$seqs_v22,
      status == "name only in v22" ~ seqs_v22 %in% names_v23$seqs_v23,
      TRUE ~ NA
    )
  ) |>
  select(
    status, mat_name, same_seq_elsewhere,
    accs_v22, accs_v23, seqs_v22, seqs_v23, n_products_v22, n_products_v23
  ) |>
  arrange(factor(status, c(
    "name only in v23", "name only in v22", "same name, sequence(s) differ",
    "same name, accession(s) differ", "unchanged"
  )), mat_name)

write.csv(diff_names, file.path(out_dir, "aae-mirbase-v22-vs-v23-names.csv"),
  row.names = FALSE
)

# ==== SUMMARY ====
cat("\n== aae mature miRNA names, miRBase v22.1 -> v23.1 ==\n")
print(count(diff_names, status))
cat("\nNames in v22.1:", nrow(names_v22), " names in v23.1:", nrow(names_v23), "\n")
renamed_in <- sum(diff_names$status == "name only in v23" &
  diff_names$same_seq_elsewhere, na.rm = TRUE)
renamed_out <- sum(diff_names$status == "name only in v22" &
  diff_names$same_seq_elsewhere, na.rm = TRUE)
cat(
  "Of the ", sum(diff_names$status == "name only in v23"),
  " names only in v23.1, ", renamed_in,
  " carry a sequence that already existed in v22.1 under another name",
  " (a rename, not a new miRNA).\n",
  "Of the ", sum(diff_names$status == "name only in v22"),
  " names only in v22.1, ", renamed_out,
  " have their sequence back in v23.1 under a different name.\n",
  sep = ""
)
