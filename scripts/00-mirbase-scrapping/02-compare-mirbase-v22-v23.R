# ~~~~~ COMPARE miRBase v22.1 vs v23.1 (Aedes aegypti) ~~~~~
# What changed in miRBase itself between v22.1 and v23.1, at two levels:
#   - mature miRNAs: unchanged, renamed, sequence changed, extra sequence on the
#     same accession, new in v23, removed
#   - precursors (hairpins): same, renamed, new, removed
#
# The unit for mature miRNAs is the pair (mature accession, sequence), not the
# accession alone: in v23.1 MIMAT0014223 is 21 nt on aae-mir-276-1 but 22 nt on
# aae-mir-276-2. Precursors that share the same mature product are collapsed.
#
# Inputs : databases/00-mirbase-scrapping/aae-v22.csv, aae-v23.csv (scraped)
# Outputs: results/00-mirbase-v23/aae-mirbase-v22-vs-v23.csv
#          results/00-mirbase-v23/aae-mirbase-v22-vs-v23-precursors.csv
#
# Run from the project root:
#   Rscript scripts/00-mirbase-scrapping/02-compare-mirbase-v22-v23.R

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
v22 <- mirbase_long(file.path(in_dir, "aae-v22.csv"))
v23 <- mirbase_long(file.path(in_dir, "aae-v23.csv"))

# ==== MATURE miRNAs ====
# 1a. Same accession AND same sequence
same_acc_seq <- inner_join(v22, v23,
  by = c("mat_acc", "mat_seq"),
  suffix = c("_v22", "_v23")
) |>
  mutate(
    seq_v22 = mat_seq, seq_v23 = mat_seq,
    status = if_else(mat_name_v22 == mat_name_v23, "unchanged", "renamed"),
    detail = if_else(status == "renamed",
      paste0(mat_name_v22, " -> ", mat_name_v23), NA_character_
    )
  )

v22_left <- anti_join(v22, v23, by = c("mat_acc", "mat_seq"))
v23_left <- anti_join(v23, v22, by = c("mat_acc", "mat_seq"))

# 1b. Same accession, different sequence. Pair every v23 sequence that is new
#     for an existing accession with the v22 sequence(s) of that accession.
#     If the old v22 sequence also survives in v23 under the same accession,
#     the accession now has TWO sequences (e.g. MIMAT0014223, aae-miR-276-3p).
seq_changed <- inner_join(
  v22 |> filter(mat_acc %in% v23_left$mat_acc) |> rename(seq_v22 = mat_seq),
  v23_left |> filter(mat_acc %in% v22$mat_acc) |> rename(seq_v23 = mat_seq),
  by = "mat_acc", suffix = c("_v22", "_v23"), relationship = "many-to-many"
) |>
  mutate(
    old_kept = paste(mat_acc, seq_v22) %in% paste(v23$mat_acc, v23$mat_seq),
    status = if_else(old_kept,
      "extra sequence on same accession", "sequence changed"
    ),
    detail = paste0(
      seq_relation(seq_v22, seq_v23),
      if_else(seed(seq_v22) != seed(seq_v23), " (SEED CHANGED)", "")
    )
  )

# 1c. Accession only in v22 = removed (or the sequence moved to a new accession)
removed <- v22_left |>
  filter(!mat_acc %in% v23$mat_acc) |>
  rename(seq_v22 = mat_seq, mat_name_v22 = mat_name, precursors_v22 = precursors) |>
  left_join(v23 |> select(seq_v22 = mat_seq, moved_to = mat_acc),
    by = "seq_v22"
  ) |>
  mutate(
    status = "removed",
    detail = if_else(!is.na(moved_to),
      paste0("same sequence now under ", moved_to), "accession absent in v23"
    )
  )

# 1d. Accession only in v23 = new (or a sequence that existed under another acc)
added <- v23_left |>
  filter(!mat_acc %in% v22$mat_acc) |>
  rename(seq_v23 = mat_seq, mat_name_v23 = mat_name, precursors_v23 = precursors) |>
  left_join(v22 |> select(seq_v23 = mat_seq, was = mat_acc),
    by = "seq_v23"
  ) |>
  mutate(
    status = "new in v23",
    detail = if_else(!is.na(was),
      paste0("sequence already existed in v22 as ", was), "new sequence"
    )
  )

diff_v22_v23 <- bind_rows(same_acc_seq, seq_changed, removed, added) |>
  select(
    status, detail, mat_acc, mat_name_v22, mat_name_v23,
    seq_v22, seq_v23, precursors_v22, precursors_v23
  ) |>
  arrange(factor(status, c(
    "sequence changed", "extra sequence on same accession", "renamed",
    "new in v23", "removed", "unchanged"
  )), mat_acc)

write.csv(diff_v22_v23, file.path(out_dir, "aae-mirbase-v22-vs-v23.csv"),
  row.names = FALSE
)

# ==== PRECURSORS (HAIRPINS) ====
pre <- function(path) {
  read.csv(path, na.strings = c("", "NA")) |>
    transmute(pre_acc = acc_mirb, pre_name = pre_mirna_name, pre_seq = toupper(pre_seq))
}
pre_v22 <- pre(file.path(in_dir, "aae-v22.csv"))
pre_v23 <- pre(file.path(in_dir, "aae-v23.csv"))

diff_pre <- full_join(pre_v22, pre_v23, by = "pre_acc", suffix = c("_v22", "_v23")) |>
  mutate(status = case_when(
    is.na(pre_name_v23) ~ "removed",
    is.na(pre_name_v22) ~ "new in v23",
    pre_seq_v22 != pre_seq_v23 ~ "hairpin sequence changed",
    pre_name_v22 != pre_name_v23 ~ "renamed",
    TRUE ~ "unchanged"
  )) |>
  select(status, pre_acc, pre_name_v22, pre_name_v23, pre_seq_v22, pre_seq_v23) |>
  arrange(status, pre_acc)

write.csv(diff_pre, file.path(out_dir, "aae-mirbase-v22-vs-v23-precursors.csv"),
  row.names = FALSE
)

# ==== SUMMARY ====
cat("\n== Mature miRNAs (accession + sequence), v22.1 -> v23.1 ==\n")
print(count(diff_v22_v23, status))
cat("\n== Precursors, v22.1 -> v23.1 ==\n")
print(count(diff_pre, status))
