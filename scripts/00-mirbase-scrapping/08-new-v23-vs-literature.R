# ~~~~~ REVERSE VIEW: EVERY NEW/CHANGED v23 miRNA vs THE LITERATURE ~~~~~
# Script 05 asks "what is this paper's miRNA in v23?". This one asks the
# opposite: for each aae mature product that is new or changed in miRBase
# v23.1, is there any paper in the extract that reports it as differentially
# expressed, under any of the four infections (denv, zika, chikv, wolbachia)?
#
# Two kinds of evidence, kept apart:
#   sequence_evidence   a paper's own reported sequence matches this v23
#                       mature product exactly or as an isomiR  -> direct.
#   name_only_evidence  the paper named the locus but not the arm, and this
#                       v23 arm is one of the new arms at that locus
#                       -> a candidate, not evidence.
#
# Input: results/00-mirbase-v23/literature-all-vs-v23-vs-s1.csv (script 05)
#        databases/00-mirbase-scrapping/aae-v22.csv, aae-v23.csv
# Output: results/00-mirbase-v23/new-v23-mirnas-literature-evidence.csv
#
# Run from the project root (after 05-):
#   Rscript scripts/00-mirbase-scrapping/08-new-v23-vs-literature.R

library(dplyr)
library(stringr)
library(tidyr)

in_dir <- "databases/00-mirbase-scrapping"
out_dir <- "results/00-mirbase-v23"
source("scripts/00-mirbase-scrapping/mirbase-helpers.R")

v22 <- mirbase_long(file.path(in_dir, "aae-v22.csv"))
v23 <- mirbase_long(file.path(in_dir, "aae-v23.csv")) |>
  mutate(
    same_pair = paste(mat_acc, mat_seq) %in% paste(v22$mat_acc, v22$mat_seq),
    known_acc = mat_acc %in% v22$mat_acc,
    v22_status = case_when(
      same_pair ~ "in v22.1",
      known_acc ~ "sequence changed in v23",
      TRUE ~ "no, new in v23"
    )
  ) |>
  filter(v22_status != "in v22.1")

lit <- read.csv(file.path(out_dir, "literature-all-vs-v23-vs-s1.csv"),
                na.strings = c("", "NA"))

# ==== Direct: the paper's own sequence matched this v23 mature product ====
by_seq <- lit |>
  filter(!is.na(v23_name), v23_match %in% c("exact", "isomiR")) |>
  separate_longer_delim(c(v23_name, v23_acc), " | ") |>
  transmute(mat_acc = v23_acc,
            note = paste0(infection, ": ", study, " ", mirna_reported, " ",
                          direction, " [", v23_match, "]")) |>
  distinct() |>
  group_by(mat_acc) |>
  summarise(sequence_evidence = paste(note, collapse = " ; "), .groups = "drop")

# ==== Candidate: the paper named the locus, and this arm is new at it ====
by_name <- lit |>
  filter(is.na(seq_reported), !is.na(new_arms), new_arms != "") |>
  separate_longer_delim(new_arms, "; ") |>
  transmute(mat_name = new_arms,
            note = paste0(infection, ": ", study, " ", mirna_reported, " ",
                          direction, " [name only, arm not given]")) |>
  distinct() |>
  group_by(mat_name) |>
  summarise(name_only_evidence = paste(note, collapse = " ; "), .groups = "drop")

out <- v23 |>
  select(mat_acc, mat_name, mat_seq, v22_status) |>
  left_join(by_seq, by = "mat_acc") |>
  left_join(by_name, by = "mat_name") |>
  mutate(across(c(sequence_evidence, name_only_evidence),
                ~ coalesce(.x, "none found"))) |>
  arrange(sequence_evidence == "none found",
          name_only_evidence == "none found", mat_name)

write.csv(out, file.path(out_dir, "new-v23-mirnas-literature-evidence.csv"),
          row.names = FALSE)

cat("New or changed v23 mature products:", nrow(out), "\n")
cat("With a paper sequence match:", sum(out$sequence_evidence != "none found"), "\n")
cat("Candidates by name only:", sum(out$name_only_evidence != "none found"), "\n\n")
print(out |> filter(sequence_evidence != "none found") |>
        select(mat_name, v22_status, sequence_evidence))
