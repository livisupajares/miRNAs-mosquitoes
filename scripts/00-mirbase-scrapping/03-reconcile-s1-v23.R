# ~~~~~ RECONCILE TABLE S1 WITH miRBase v23.1 ~~~~~
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
#   Rscript scripts/00-mirbase-scrapping/03-reconcile-s1-v23.R
# (the miRBase v22 vs v23 comparison itself is 02-compare-mirbase-v22-v23.R)

# ==== IMPORT LIBRARIES =====
library(dplyr)
library(stringr)
library(tidyr)
library(readxl)

# ==== PATHS ====
in_dir <- "databases/00-mirbase-scrapping"
out_dir <- "results/00-mirbase-v23"
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

source("scripts/00-mirbase-scrapping/mirbase-helpers.R")

# ==== IMPORT DATA ====
v22 <- mirbase_long(file.path(in_dir, "aae-v22.csv"))
v23 <- mirbase_long(file.path(in_dir, "aae-v23.csv"))

# ==== PART 2: TABLE S1 (aae) vs miRBase v23.1 ====
s1_raw <- read_excel(file.path(in_dir, "table-s1.xlsx"), sheet = "Aedes aegypti", na = c("", "NA"))

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
s1_aal <- read_excel(file.path(in_dir, "table-s1.xlsx"), sheet = "Aedes albopictus", na = c("", "NA")) |>
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

# ==== PART 4: EVERY v23.1 MATURE miRNA -> IS IT IN TABLE S1? ====
# The reverse view, so every miRBase entry can be checked by hand.
# S1 only lists miRNAs that a reviewed study reported as differentially
# expressed, so most miRBase entries are expected to be absent from S1.
s1_rows <- s1_raw |>
  mutate(excel_row = row_number() + 1, s1_seq = clean_seq(mat_seq))

v23_in_s1 <- v23 |>
  mutate(
    in_v22 = case_when(
      paste(mat_acc, mat_seq) %in% paste(v22$mat_acc, v22$mat_seq) ~ "yes, same accession and sequence",
      mat_acc %in% v22$mat_acc ~ "accession yes, sequence changed",
      TRUE ~ "no, new in v23"
    ),
    s1_exact_rows = sapply(mat_seq, function(s) {
      paste(s1_rows$excel_row[s1_rows$s1_seq %in% s], collapse = ",")
    }),
    s1_exact_names = sapply(mat_seq, function(s) {
      paste(unique(s1_rows$mirna_name[s1_rows$s1_seq %in% s]), collapse = "; ")
    }),
    s1_isomir_names = sapply(mat_seq, function(s) {
      hit <- !is.na(s1_rows$s1_seq) & s1_rows$s1_seq != s &
        (str_detect(s1_rows$s1_seq, fixed(s)) | str_detect(s, fixed(coalesce(s1_rows$s1_seq, "X"))))
      paste(unique(s1_rows$mirna_name[hit]), collapse = "; ")
    }),
    s1_acc_names = sapply(mat_acc, function(a) {
      paste(unique(s1_rows$mirna_name[s1_rows$acc_mirb %in% a]), collapse = "; ")
    }),
    s1_denv = sapply(mat_seq, function(s) {
      any(s1_rows$s1_seq %in% s & s1_rows$infection %in% "denv")
    }),
    in_s1 = case_when(
      s1_exact_rows != "" ~ "yes, exact sequence",
      s1_isomir_names != "" ~ "only as an isomiR (length variant)",
      s1_acc_names != "" ~ "only by accession (different sequence)",
      TRUE ~ "no"
    )
  ) |>
  select(mat_acc, mat_name, mat_seq, in_v22, in_s1, s1_denv, s1_exact_names,
    s1_exact_rows, s1_isomir_names, s1_acc_names, precursors
  ) |>
  arrange(in_s1, mat_name)

write.csv(v23_in_s1, file.path(out_dir, "aae-mirbase-v23-in-s1.csv"),
  row.names = FALSE
)

# ==== SUMMARY ====
cat("\n== Table S1 aae entries vs v23.1 (all conditions) ==\n")
print(count(s1_vs_v23, status))
cat("\n== Table S1 aae DENV-2 entries vs v23.1 ==\n")
print(count(s1_denv_vs_v23, status))
cat("\n== Table S1 aal entries vs aae v23.1 ==\n")
print(count(s1_aal, match_type, name_agrees))
cat("\n== Every aae v23.1 mature miRNA: in miRBase v22.1? in Table S1? ==\n")
print(count(v23_in_s1, in_v22, in_s1))
