# ~~~~~ BUILD THE miRBase v23.1 VERSION OF THE aae miRNA TABLE ~~~~~
# Takes Table S1 (read-only) and applies the v23.1 update with one rule,
# agreed with Liv on 2026-11-25:
#   "Use the miRBase v23.1 sequence, unless the paper gave its own sequence."
# In practice:
#   - S1 sequence identical to the v22.1 miRBase sequence -> it came from
#     miRBase, so take the v23.1 sequence and name.
#   - S1 sequence that is not a v22.1 miRBase sequence -> the paper reported
#     it, so keep it as is.
#   - Anything ambiguous is kept as in S1 and flagged `needs_review = TRUE`.
#   - Manual calls live in databases/00-mirbase-scrapping/v23-manual-decisions.csv
#     (one row per decision, with a note), never in S1.
#
# Requires the output of 02-reconcile-v22-v23-s1.R. Run from the project root:
#   Rscript scripts/00-mirbase-scrapping/02-reconcile-v22-v23-s1.R
#   Rscript scripts/00-mirbase-scrapping/03-build-aae-mirna-v23.R

# ==== IMPORT LIBRARIES =====
library(dplyr)
library(stringr)
library(readxl)

# ==== HELPERS ====
clean_seq <- function(x) {
  x <- str_remove_all(str_replace_all(toupper(as.character(x)), "T", "U"), "[^ACGU]")
  if_else(is.na(x) | x == "", NA_character_, x)
}
strip_species <- function(x) str_remove_all(x, "(^|(?<=; ))[a-z]{3}-")

# ==== IMPORT DATA ====
s1 <- read_excel("databases/00-mirbase-scrapping/table-s1.xlsx",
  sheet = "Aedes aegypti", na = c("", "NA") # S1 stores missing values as the text "NA"
)
recon <- read.csv("results/00-mirbase-v23/s1-aae-vs-mirbase-v23.csv",
  na.strings = c("", "NA")
) |>
  # write.csv quotes the string "NA", which read.csv then keeps as text
  mutate(across(where(is.character), ~ na_if(.x, "NA")))
manual <- read.csv("databases/00-mirbase-scrapping/v23-manual-decisions.csv",
  na.strings = c("", "NA")
)

# ==== ONE ACTION PER DISTINCT S1 ENTRY ====
actions <- recon |>
  group_by(acc_s1, name_s1, s1_seq) |>
  mutate(n_matches = n()) |>
  slice(1) |>
  ungroup() |>
  mutate(
    v23_name_short = strip_species(v23_name),
    ambiguous = n_matches > 1 | str_detect(coalesce(v23_name, ""), ";"),
    v23_action = case_when(
      ambiguous ~ "kept S1: several v23 matches",
      status == "OK: unchanged" ~ "unchanged",
      status == "OK: rename only" ~ "renamed to v23",
      str_starts(status, "UPDATE") ~ "sequence and name updated to v23",
      str_starts(status, "FIX") ~ "accession fixed to v23 mature",
      str_starts(status, "NEW") ~ "accession added from v23",
      status == "NOT IN miRBase v23" ~ "unchanged (not in miRBase)",
      TRUE ~ "kept S1: paper's own sequence or conflict"
    ),
    take_v23 = !ambiguous & v23_action %in% c(
      "renamed to v23", "sequence and name updated to v23",
      "accession fixed to v23 mature", "accession added from v23"
    ),
    final_acc = if_else(take_v23, v23_acc, acc_s1),
    final_name = if_else(take_v23, v23_name_short, name_s1),
    final_seq = if_else(
      take_v23 & v23_action == "sequence and name updated to v23",
      v23_seq, s1_seq
    ),
    needs_review = ambiguous | str_starts(status, "CHECK") |
      str_starts(status, "NEW") | str_detect(status, "SEED DIFFERS"),
    v23_note = paste0(status, " | ", match_type)
  ) |>
  select(acc_s1, name_s1, s1_seq, final_acc, final_name, final_seq,
    v23_action, needs_review, v23_note
  )

# ==== APPLY MANUAL DECISIONS (override the automatic action) ====
actions <- actions |>
  left_join(manual, by = c("name_s1", "s1_seq"), suffix = c("", ".manual")) |>
  mutate(
    is_manual = !is.na(note),
    final_acc = if_else(is_manual, final_acc.manual, final_acc),
    final_name = if_else(is_manual, final_name.manual, final_name),
    final_seq = if_else(is_manual, final_seq.manual, final_seq),
    v23_action = if_else(is_manual, "manual decision", v23_action),
    needs_review = if_else(is_manual, needs_liv_check, needs_review),
    v23_note = if_else(is_manual, paste0(note, " | ", v23_note), v23_note)
  ) |>
  select(!c(ends_with(".manual"), is_manual, needs_liv_check, note))

# ==== BUILD THE NEW TABLE (S1 columns, values updated, originals kept) ====
aae_v23 <- s1 |>
  mutate(s1_seq = clean_seq(mat_seq)) |>
  left_join(actions,
    by = c("acc_mirb" = "acc_s1", "mirna_name" = "name_s1", "s1_seq")
  ) |>
  mutate(
    acc_mirb_s1 = acc_mirb, mirna_name_s1 = mirna_name, mat_seq_s1 = mat_seq,
    acc_mirb = final_acc, mirna_name = final_name, mat_seq = final_seq
  ) |>
  select(!c(s1_seq, final_acc, final_name, final_seq))

stopifnot(nrow(aae_v23) == nrow(s1))

write.csv(aae_v23, "databases/01-isolating-mature-sequences/aae-mirna-v23.csv",
  row.names = FALSE
)

# ==== SUMMARY ====
cat("\n== Actions on S1 aae rows ==\n")
print(count(aae_v23, v23_action, needs_review))
cat("\n== DENV-2 rows that changed or need review ==\n")
aae_v23 |>
  filter(infection %in% "denv", v23_action != "unchanged" | needs_review) |>
  select(mirna_name_s1, mirna_name, acc_mirb, mat_seq, v23_action, needs_review) |>
  as.data.frame() |>
  print()
