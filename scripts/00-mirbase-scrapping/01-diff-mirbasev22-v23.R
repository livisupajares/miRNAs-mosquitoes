# ~~~~~ DIFF CHECKER MIRBASE VERSIONS ~~~~~~ 
# This script checks which miRNAs and sequences
# are different between the previous miRBase version (22)
# and the current one (23.1)

# ==== IMPORT LIBRARIES =====
library(dplyr)
library(stringr)
library(tidyr)
library(readxl)

# ==== IMPORT DATA ====
aae_mirbase23 <- read.csv("databases/00-mirbase-scrapping/aae-v23.csv")
aae_mirbase22 <- read.csv("databases/00-mirbase-scrapping/aae-v22.csv")
table_s1 <- read_excel("databases/00-mirbase-scrapping/table-s1.xlsx",
  sheet = "Aedes aegypti", range = "A1:L263"
)

# ==== CLEAN DATA ====
# Kepp relevant columns for aae_mirbase23
aae_mirbase23_clean <- aae_mirbase23 |> select(mat_acc_mirb1, mat_name_1, mat_seq_1, mat_acc_mirb2, mat_name_2, mat_seq_2)

# Kepp relevant columns for aae_mirbase22
aae_mirbase22_clean <- aae_mirbase22 |> select(mat_acc_mirb1, mat_name_1, mat_seq_1, mat_acc_mirb2, mat_name_2, mat_seq_2)

# Remove pre seq column for table_s1
table_s1_clean <- table_s1 |>
  select(!c(pre_seq, species:pbm_time_h)) #|>
# distinct(mirna_name, .keep_all = TRUE)

# Divide aae_mirbase23_clean and add extra rows
aae_mirbase23_5p <- aae_mirbase23_clean |>
  select(!(mat_acc_mirb2:mat_seq_2)) |>
  rename(mat_acc_mirb = mat_acc_mirb1, mat_name = mat_name_1, mat_seq = mat_seq_1)

aae_mirbase23_3p <- aae_mirbase23_clean |>
  select(mat_acc_mirb2:mat_seq_2) |>
  rename(mat_acc_mirb = mat_acc_mirb2, mat_name = mat_name_2, mat_seq = mat_seq_2)

# merge aae_mirbase23_5p and aae_mirbase23_3p by rows to get a longer dataframe
aae_mirbase23_final <- bind_rows(aae_mirbase23_5p, aae_mirbase23_3p) |> drop_na()

# Divide aae_mirbase22_clean and add extra rows
aae_mirbase22_5p <- aae_mirbase22_clean |>
  select(!(mat_acc_mirb2:mat_seq_2)) |>
  rename(mat_acc_mirb = mat_acc_mirb1, mat_name = mat_name_1, mat_seq = mat_seq_1)

aae_mirbase22_3p <- aae_mirbase22_clean |>
  select(mat_acc_mirb2:mat_seq_2) |>
  rename(mat_acc_mirb = mat_acc_mirb2, mat_name = mat_name_2, mat_seq = mat_seq_2)

# merge aae_mirbase23_5p and aae_mirbase23_3p by rows to get a longer dataframe
aae_mirbase23_final <- bind_rows(aae_mirbase23_5p, aae_mirbase23_3p) |> drop_na()

# merge aae_mirbase22_5p and aae_mirbase22_3p by rows to get a longer dataframe
aae_mirbase22_final <- bind_rows(aae_mirbase22_5p, aae_mirbase22_3p) |> drop_na()

# Filter DENV-2
table_s1_denv <- table_s1_clean |>
  filter(infection == "denv") |>
  distinct(mirna_name, .keep_all = TRUE)

# ==== COMPARE DENV-2 vs MIRNA V23.1 =====

# ==== 1. CREATE MATCHING KEYS ====

# ==== 1. PREPARE DATA ====
df1_prep <- table_s1_denv %>%
  mutate(
    core_name = str_remove(mirna_name, "-[35]p$"),
    # Only consider MIMAT as a valid mature accession for Step 1
    clean_acc = if_else(str_detect(acc_mirb, "^MIMAT"), acc_mirb, NA_character_),
    id1 = row_number() # Add ID to track unmatched rows
  )

df2_prep <- aae_mirbase23_final %>%
  mutate(
    core_name = str_remove(str_remove(mat_name, "^aae-"), "-[35]p$"),
    clean_acc = if_else(str_detect(mat_acc_mirb, "^MIMAT"), mat_acc_mirb, NA_character_),
    id2 = row_number()
  )

# ==== 2. STEP 1: MATCH BY MIMAT ACCESSION ====
df1_acc <- df1_prep %>% filter(!is.na(clean_acc))
df2_acc <- df2_prep %>% filter(!is.na(clean_acc))

matched_by_acc <- inner_join(
  df1_acc, df2_acc,
  by = c("clean_acc" = "clean_acc"),
  suffix = c("_table_s1", "_v23"),
  relationship = "many-to-many"
) %>%
  mutate(match_key = clean_acc, match_type = "Accession")

# ==== 3. STEP 2: MATCH REMAINING BY CORE NAME ====
# Get rows that were NOT matched by accession (this includes MI00 and NA)
unmatched_id1 <- setdiff(df1_prep$id1, matched_by_acc$id1)
unmatched_id2 <- setdiff(df2_prep$id2, matched_by_acc$id2)

df1_rem <- df1_prep %>% filter(id1 %in% unmatched_id1)
df2_rem <- df2_prep %>% filter(id2 %in% unmatched_id2)

matched_by_name <- full_join(
  df1_rem, df2_rem,
  by = c("core_name" = "core_name"),
  suffix = c("_table_s1", "_v23"),
  relationship = "many-to-many"
) %>%
  mutate(match_key = core_name, match_type = "Core Name")

# ==== 4. COMBINE AND CLEAN ====
# Define the final column structure we want
cols_to_keep <- c(
  "match_key", "match_type", "acc_mirb_table_s1", "mirna_name_table_s1",
  "mat_seq_table_s1", "mat_acc_mirb_v23", "mat_name_v23", "mat_seq_v23"
)

diff_combined <- bind_rows(
  # For matched_by_acc: Rename the base columns to match our target structure
  matched_by_acc %>%
    rename(
      acc_mirb_table_s1 = acc_mirb,
      mirna_name_table_s1 = mirna_name,
      mat_acc_mirb_v23 = mat_acc_mirb,
      mat_name_v23 = mat_name
    ) %>%
    select(all_of(cols_to_keep)),

  # For matched_by_name: Rename the base columns to match our target structure
  matched_by_name %>%
    rename(
      acc_mirb_table_s1 = acc_mirb,
      mirna_name_table_s1 = mirna_name,
      mat_acc_mirb_v23 = mat_acc_mirb,
      mat_name_v23 = mat_name
    ) %>%
    select(all_of(cols_to_keep))
) %>%
  # Arrange by match_key to keep similar miRNAs grouped together
  arrange(match_key)

# ==== 5. SEPARATE INTO MATCHED AND BRAND NEW ====
# 5A. Matched miRNAs (Rows that successfully aligned between both datasets)
matched_df <- diff_combined %>%
  filter(!is.na(mirna_name_table_s1) & !is.na(mat_name_v23))

# 5B. Brand New / Unmatched miRNAs
brand_new <- diff_combined %>%
  filter(is.na(mirna_name_table_s1) | is.na(mat_name_v23)) %>%
  mutate(
    # Label where the unmatched miRNA came from
    origin_status = case_when(
      is.na(mirna_name_table_s1) ~ "New in v23 (Not found in table_s1)",
      is.na(mat_name_v23) ~ "In table_s1 (Missing in v23)"
    )
  )
