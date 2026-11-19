# ~~~~~ DIFF CHECKER MIRBASE VERSIONS ~~~~~~ 
# This script checks which miRNAs and sequences
# are different between the previous miRBase version (22)
# and the current one (23.1)

# ==== IMPORT LIBRARIES =====
library(dplyr)
library(tidyr)
library(readxl)

# ==== IMPORT DATA ====
aae_mirbase23 <- read.csv("databases/00-mirbase-scrapping/aae-v23.csv")
table_s1 <- read_excel("databases/00-mirbase-scrapping/table-s1.xlsx",
  sheet = "Aedes aegypti", range = "A1:L263"
)

# ==== CLEAN DATA ====
# Kepp relevant columns for aae_mirbase23
aae_mirbase23_clean <- aae_mirbase23 |> select(mat_acc_mirb1, mat_name_1, mat_seq_1, mat_acc_mirb2, mat_name_2, mat_seq_2)

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
