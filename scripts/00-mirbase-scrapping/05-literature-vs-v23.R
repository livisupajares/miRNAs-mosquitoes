# ~~~~~ LITERATURE (DENV-2, ZIKV, CHIKV, WOLBACHIA) vs miRBase v23.1 vs TABLE S1 ~~~~~
# Goal: for every miRNA a paper reports as up- or down-regulated under one of
# the four infections Table S1 covers (denv, zika, chikv, wolbachia),
#   (a) find the miRBase v23.1 mature miRNA it is (by SEQUENCE first),
#   (b) say whether that v23 miRNA is new in v23 (absent from v22.1),
#   (c) say whether Table S1 already has it for that study AND infection
#       (active sheets or "Removed studies"), so missing ones are visible.
#
# Input (hand-curated from the papers, every row has a page/figure locator):
#   databases/00-mirbase-scrapping/literature/paper-de-extract.tsv
#   databases/00-mirbase-scrapping/literature/su2017-additional-file1-seqs.tsv
# Table S1 is read only.
#
# Run from the project root (after 02- and 03-):
#   Rscript scripts/00-mirbase-scrapping/05-literature-vs-v23.R

library(dplyr)
library(stringr)
library(tidyr)
library(readxl)

in_dir <- "databases/00-mirbase-scrapping"
lit_dir <- file.path(in_dir, "literature")
out_dir <- "results/00-mirbase-v23"
source("scripts/00-mirbase-scrapping/mirbase-helpers.R")

# ==== miRBase v23.1 mature miRNAs, with "new in v23" flag ====
v22 <- mirbase_long(file.path(in_dir, "aae-v22.csv"))
v23 <- mirbase_long(file.path(in_dir, "aae-v23.csv")) |>
  mutate(new_in_v23 = !paste(mat_acc, mat_seq) %in% paste(v22$mat_acc, v22$mat_seq) &
    !mat_acc %in% v22$mat_acc)

# Precursor sequences, to give miRBase mature sequences as "start - SEQ - end"
pre <- read.csv(file.path(in_dir, "aae-v23.csv"), na.strings = c("", "NA")) |>
  transmute(pre_name = pre_mirna_name, pre_seq_raw = pre_seq,
            pre_seq = clean_seq(pre_seq))
with_pos <- function(mat_seq, precursors) {
  first_pre <- str_split_i(precursors, "; ", 1)
  p <- pre$pre_seq[match(first_pre, pre$pre_name)]
  start <- str_locate(p, fixed(mat_seq))[, 1]
  if_else(is.na(start), mat_seq,
          paste0(start, " - ", mat_seq, " - ", start + nchar(mat_seq) - 1))
}

# ==== Paper extract ====
lit <- read.delim(file.path(lit_dir, "paper-de-extract.tsv"),
                  na.strings = c("", "NA"), check.names = FALSE) |>
  mutate(row_id = row_number(), seq = clean_seq(seq_reported))

# (a) sequence match: exact, else isomiR (one contains the other, >= 17 nt)
seq_hits <- lit |>
  filter(!is.na(seq)) |>
  select(row_id, seq) |>
  cross_join(v23 |> select(mat_acc, mat_name, mat_seq, new_in_v23, precursors)) |>
  mutate(rel = seq_relation(mat_seq, seq)) |>
  filter(rel != "different sequence",
         rel == "identical" | pmin(nchar(seq), nchar(mat_seq)) >= 17) |>
  mutate(rank = if_else(rel == "identical", 0L, 1L),
         diff = abs(nchar(seq) - nchar(mat_seq))) |>
  group_by(row_id) |>
  arrange(rank, diff, .by_group = TRUE) |>
  summarise(
    v23_match = if_else(first(rank) == 0L, "exact", "isomiR"),
    v23_name = paste(unique(mat_name[rank == first(rank) & diff == first(diff)]), collapse = " | "),
    v23_acc = paste(unique(mat_acc[rank == first(rank) & diff == first(diff)]), collapse = " | "),
    v23_seq = first(mat_seq),
    v23_seq_pos = with_pos(first(mat_seq), first(precursors)),
    v23_relation = first(rel),
    v23_new = any(new_in_v23[rank == first(rank) & diff == first(diff)]),
    .groups = "drop"
  )

# (b) name-only fallback for rows without a sequence: list every v23 arm of
#     the same locus, because the paper did not say which arm it measured.
norm_base <- function(x) {
  x |> strip_species() |> str_remove("\\*$") |> str_remove("-[35]p$") |>
    str_replace("^mir-", "miR-") |> tolower()
}
locus_id <- function(base) str_extract(base, "^(mir|let|bantam)-?[0-9a-z]*?[0-9]+")

v23_base <- v23 |>
  separate_longer_delim(mat_name, "; ") |>
  mutate(base = norm_base(mat_name)) |>
  group_by(base) |>
  summarise(name_candidates = paste(sort(unique(mat_name)), collapse = "; "),
            any_new = any(new_in_v23),
            new_arms = paste(sort(unique(mat_name[new_in_v23])), collapse = "; "),
            .groups = "drop")

res <- lit |>
  left_join(seq_hits, by = "row_id") |>
  mutate(base = norm_base(mirna_reported), arm = get_arm(mirna_reported)) |>
  left_join(v23_base, by = "base") |>
  mutate(
    v23_match = case_when(
      !is.na(v23_match) ~ v23_match,
      !is.na(seq) ~ "no match (not an aae miRBase v23 sequence)",
      !is.na(name_candidates) ~ "name only (arm unknown)",
      TRUE ~ "name only, no aae v23 locus"
    ),
    v23_new = if_else(is.na(seq), NA, coalesce(v23_new, FALSE))
  )

# ==== (c) Is it in Table S1 for the same study? ====
read_s1 <- function(sheet) {
  read_excel(file.path(in_dir, "table-s1.xlsx"), sheet = sheet, na = c("", "NA")) |>
    transmute(sheet = sheet, citation_exp, infection, mirna_name,
              mat_seq_s1 = clean_seq(mat_seq),
              base = norm_base(mirna_name), arm = get_arm(mirna_name))
}
s1 <- bind_rows(read_s1("Aedes aegypti"), read_s1("Aedes albopictus"),
                read_s1("Removed studies"))

s1_hit <- res |>
  select(row_id, study, infection, seq, base, arm) |>
  inner_join(s1, by = c("study" = "citation_exp", "infection"),
             relationship = "many-to-many") |>
  mutate(by_seq = !is.na(seq) & !is.na(mat_seq_s1) &
           (seq == mat_seq_s1 | str_detect(seq, fixed(mat_seq_s1)) |
              str_detect(mat_seq_s1, fixed(seq))),
         # same locus and same arm (or one side gives no arm)
         by_name = base.x == base.y & (is.na(arm.x) | is.na(arm.y) | arm.x == arm.y),
         # same locus number, different letter/arm (e.g. paper "miR-33",
         # S1 "miR-33b-5p"): reported so a human can confirm
         by_locus = locus_id(base.x) == locus_id(base.y)) |>
  filter(by_seq | by_name | by_locus) |>
  group_by(row_id) |>
  summarise(
    in_s1 = case_when(
      any(sheet != "Removed studies" & (by_seq | by_name)) ~ "yes",
      any(sheet != "Removed studies") ~ "yes, but S1 name differs (check)",
      TRUE ~ "only in Removed studies"
    ),
    s1_names = paste(unique(paste0(mirna_name, " [", sheet, "]")), collapse = "; "),
    .groups = "drop"
  )

out <- res |>
  left_join(s1_hit, by = "row_id") |>
  mutate(in_s1 = coalesce(in_s1, "NO - missing from Table S1")) |>
  select(study, infection, species, system, comparison, mirna_reported, seq_reported, seq_source,
         direction, logFC, p, locator, v23_match, v23_name, v23_acc, v23_seq_pos,
         v23_relation, v23_new, name_candidates, new_arms, in_s1, s1_names)

write.csv(out, file.path(out_dir, "literature-all-vs-v23-vs-s1.csv"), row.names = FALSE)

# ==== Console summary ====
cat("Rows (study x miRNA x condition):", nrow(out), "\n")
print(count(out, infection, study, in_s1))
cat("\nSequence matches to miRNAs NEW in v23:\n")
print(out |> filter(v23_new %in% TRUE) |>
        select(infection, study, mirna_reported, direction, v23_match, v23_name, in_s1))
cat("\nName-only rows whose locus has a NEW v23 arm (arm unknown):\n")
print(out |> filter(is.na(seq_reported), new_arms != "") |>
        select(infection, study, mirna_reported, direction, new_arms, in_s1))
