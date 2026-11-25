# ~~~~~ RECONCILE miRBase v22.1, miRBase v23.1 AND TABLE S1 ~~~~~
# Goal: find out exactly what the miRBase v23.1 update changes for the
# miRNAs curated in Table S1, WITHOUT touching Table S1 itself.
#
# Design rules (why this is different from 01-diff-mirbasev22-v23.R):
#   1. The unit of comparison is a MATURE miRNA = (mature accession, sequence).
#      The same MIMAT accession can carry two different sequences in v23
#      (e.g. MIMAT0014223 is 21 nt on aae-mir-276-1 and 22 nt on
#      aae-mir-276-2), so accession alone is not a safe key.
#   2. Sequence is the primary key. Accession and name are only used to
#      explain a match or to flag disagreements for manual review.
#   3. Names are normalised (species prefix dropped) before comparing, and the
#      arm (-5p/-3p) is compared separately, because miRBase v22 often gave no
#      arm while papers did.
#   4. Table S1 is read-only ground truth. Results go to new files in
#      results/00-mirbase-v23/.
#
# Run from the project root:
#   Rscript scripts/00-mirbase-scrapping/02-reconcile-v22-v23-s1.R

# ==== IMPORT LIBRARIES =====
library(dplyr)
library(stringr)
library(tidyr)
library(readxl)

# ==== PATHS ====
in_dir <- "databases/00-mirbase-scrapping"
out_dir <- "results/00-mirbase-v23"
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

# ==== HELPER FUNCTIONS ====
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

# ==== IMPORT DATA ====
v22 <- mirbase_long(file.path(in_dir, "aae-v22.csv"))
v23 <- mirbase_long(file.path(in_dir, "aae-v23.csv"))

# ==== PART 1: miRBase v22.1 -> v23.1 (aae) ====
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

# ==== PART 2: TABLE S1 (aae) vs miRBase v23.1 ====
s1_raw <- read_excel(file.path(in_dir, "table-s1.xlsx"), sheet = "Aedes aegypti")

s1 <- s1_raw |>
  mutate(excel_row = row_number() + 1, s1_seq = clean_seq(mat_seq)) |>
  group_by(acc_s1 = acc_mirb, name_s1 = mirna_name, s1_seq) |>
  summarise(
    excel_rows = paste(excel_row, collapse = ","),
    n_entries = n(),
    infections = paste(sort(unique(na.omit(infection))), collapse = ","),
    denv_regulation = paste(sort(unique(na.omit(exp_DENV))), collapse = ","),
    studies = paste(unique(citation_exp), collapse = "; "),
    .groups = "drop"
  )

# For each S1 sequence, find v23 matches: exact first, then containment
match_one <- function(s) {
  if (is.na(s)) {
    return(tibble(match_type = "no sequence in S1"))
  }
  exact <- v23 |> filter(mat_seq == s)
  if (nrow(exact) > 0) {
    return(exact |> transmute(
      match_type = "exact sequence",
      v23_acc = mat_acc, v23_name = mat_name, v23_seq = mat_seq
    ))
  }
  part <- v23 |> filter(str_detect(mat_seq, fixed(s)) | str_detect(s, fixed(mat_seq)))
  if (nrow(part) > 0) {
    return(part |> transmute(
      match_type = paste0("isomiR: ", seq_relation(s, mat_seq)),
      v23_acc = mat_acc, v23_name = mat_name, v23_seq = mat_seq
    ))
  }
  tibble(match_type = "no sequence match")
}

s1_vs_v23 <- s1 |>
  mutate(m = lapply(s1_seq, match_one)) |>
  unnest(m) |>
  # Fall back to the S1 accession when the sequence found nothing
  left_join(
    v23 |> select(acc_s1 = mat_acc, acc_v23_name = mat_name, acc_v23_seq = mat_seq),
    by = "acc_s1", relationship = "many-to-many"
  ) |>
  mutate(
    s1_seq_in_v22 = s1_seq %in% v22$mat_seq,
    acc_is_precursor = str_detect(coalesce(acc_s1, ""), "^MI\\d"),
    acc_agrees = !is.na(v23_acc) & coalesce(acc_s1, "") == v23_acc,
    name_agrees = !is.na(v23_name) & strip_species(v23_name) == name_s1,
    base_agrees = !is.na(v23_name) & get_base(v23_name) == get_base(name_s1),
    seed_same = is.na(v23_seq) | seed(s1_seq) == seed(v23_seq),
    status = case_when(
      match_type == "exact sequence" & acc_agrees & name_agrees ~ "OK: unchanged",
      match_type == "exact sequence" & acc_agrees ~ "OK: rename only",
      match_type == "exact sequence" & !v23_acc %in% v22$mat_acc ~
        "NEW: now in miRBase (accession new in v23)",
      match_type == "exact sequence" & acc_is_precursor ~
        "FIX: S1 has precursor (MI) accession, use mature",
      match_type == "exact sequence" & is.na(acc_s1) ~ "FIX: S1 accession missing",
      match_type == "exact sequence" ~ "CHECK: sequence matches a different accession",
      # S1 copied the v22 sequence and miRBase has since changed it
      str_starts(match_type, "isomiR") & acc_agrees & s1_seq_in_v22 & seed_same ~
        "UPDATE: v23 changed sequence (S1 has v22 seq), same seed",
      str_starts(match_type, "isomiR") & acc_agrees & s1_seq_in_v22 ~
        "UPDATE: v23 changed sequence (S1 has v22 seq), SEED DIFFERS",
      str_starts(match_type, "isomiR") & seed_same ~ "CHECK: isomiR, same seed",
      str_starts(match_type, "isomiR") ~ "CHECK: isomiR, SEED DIFFERS",
      !is.na(acc_v23_seq) ~ "CHECK: accession exists but sequence differs",
      TRUE ~ "NOT IN miRBase v23"
    )
  ) |>
  # Only keep the accession fallback columns when they were needed
  mutate(across(c(acc_v23_name, acc_v23_seq), ~ if_else(is.na(v23_acc), .x, NA_character_))) |>
  distinct() |>
  select(
    status, name_s1, acc_s1, s1_seq, match_type, v23_acc, v23_name, v23_seq,
    acc_v23_name, acc_v23_seq, s1_seq_in_v22, seed_same,
    denv_regulation, infections, n_entries, excel_rows, studies
  ) |>
  arrange(status, name_s1)

write.csv(s1_vs_v23, file.path(out_dir, "s1-aae-vs-mirbase-v23.csv"),
  row.names = FALSE
)

# DENV-2 subset: these are the ones that feed target prediction
s1_denv_vs_v23 <- s1_vs_v23 |> filter(str_detect(infections, "denv"))
write.csv(s1_denv_vs_v23, file.path(out_dir, "s1-aae-denv-vs-mirbase-v23.csv"),
  row.names = FALSE
)

# ==== PART 3: TABLE S1 (aal) vs miRBase v23.1 aae (naming help only) ====
# There is no A. albopictus in miRBase. An identical aae mature sequence is a
# useful hint for the canonical name/arm, not proof of identity.
s1_aal <- read_excel(file.path(in_dir, "table-s1.xlsx"), sheet = "Aedes albopictus") |>
  mutate(excel_row = row_number() + 1, s1_seq = clean_seq(mat_seq)) |>
  group_by(name_s1 = mirna_name, s1_seq) |>
  summarise(
    excel_rows = paste(excel_row, collapse = ","),
    infections = paste(sort(unique(na.omit(infection))), collapse = ","),
    denv_regulation = paste(sort(unique(na.omit(exp_DENV))), collapse = ","),
    studies = paste(unique(citation_exp), collapse = "; "),
    .groups = "drop"
  ) |>
  mutate(m = lapply(s1_seq, match_one)) |>
  unnest(m) |>
  mutate(
    name_agrees = !is.na(v23_name) & strip_species(v23_name) == name_s1,
    seed_same = is.na(v23_seq) | seed(s1_seq) == seed(v23_seq)
  ) |>
  select(
    name_s1, s1_seq, match_type, aae_v23_acc = v23_acc,
    aae_v23_name = v23_name, aae_v23_seq = v23_seq, name_agrees, seed_same,
    denv_regulation, infections, excel_rows, studies
  )

write.csv(s1_aal, file.path(out_dir, "s1-aal-vs-aae-mirbase-v23.csv"),
  row.names = FALSE
)

# ==== SUMMARY ====
cat("\n== miRBase v22.1 -> v23.1 (aae mature miRNAs) ==\n")
print(count(diff_v22_v23, status))
cat("\n== Table S1 aae entries vs v23.1 (all conditions) ==\n")
print(count(s1_vs_v23, status))
cat("\n== Table S1 aae DENV-2 entries vs v23.1 ==\n")
print(count(s1_denv_vs_v23, status))
cat("\n== Table S1 aal entries vs aae v23.1 ==\n")
print(count(s1_aal, match_type, name_agrees))
