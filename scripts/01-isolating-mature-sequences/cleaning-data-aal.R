# ~~~~~ ISOLATING AEDES ALBOPICTUS MIRNA SEQUENCES ~~~~~~
#
# ===== Load libraries & files =====
library(dplyr)
source("scripts/functions.R")

# ===== Importing data =====
# Add NA to all empty spaces
aal_mirna <- read.csv("databases/01-isolating-mature-sequences/aal-mirna.csv",
  na.strings = c("", "NA")
)

# Add aal- before miRNA name
aal_mirna$mirna_name <- paste0("aal-", aal_mirna$mirna_name)
# Total number of unique miRNAs
length(unique(aal_mirna$mirna_name)) # 118

# ===== Deleting extra columns =====
# Show name of columns
colnames(aal_mirna)
aal_mirna_mat_subset <- aal_mirna[-c(2, 4:20, 23:43, 45)]

# ==== Deleting data that aren't nucleotides ====
# Delete NA rows with NA values only from the column mat_seq
aal_mirna_mat_subset <- subset(aal_mirna_mat_subset, !(is.na(mat_seq)))
# Total number of unique miRNAs
length(unique(aal_mirna_mat_subset$mirna_name)) # 118

# ==== Deleting data that is not from DENV-2 ====
# Filter by denv infection
aal_mirna_mat_denv <- aal_mirna_mat_subset[grepl(
  "denv",
  aal_mirna_mat_subset$infection
), ]
# Total number of unique miRNAs
length(unique(aal_mirna_mat_denv$mirna_name)) # 51

# ==== Deleting duplicated rows based on miRNA_name ====
# Some duplicates have both up-regulated and down-regulated in the same miRNA.

# Identify miRNAs with both up and down regulation
problematic_mirnas <- aal_mirna_mat_denv |>
  group_by(mirna_name) |>
  filter("up-regulated" %in% exp_DENV & "down-regulated" %in% exp_DENV) |>
  pull(mirna_name) |>
  unique()

print(problematic_mirnas)

# Remove rows where mirna_name is in problematic_mirnas
aal_mirna_mat_denv_up <- aal_mirna_mat_denv |>
  # Remove problematic miRNAs
  filter(!mirna_name %in% problematic_mirnas) |>
  # Keep only up-regulated miRNAs
  filter(exp_DENV == "up-regulated") |>
  # Remove duplicate miRNA names, keeping the first occurrence
  distinct(mirna_name, .keep_all = TRUE)
# Total number of unique miRNAs
length(unique(aal_mirna_mat_denv_up$mirna_name)) # 24

# Deleting the infection column
aal_mirna_mat_denv_final <- aal_mirna_mat_denv_up[-c(3:5)]

# ==== Replace all Ts into Us ====
aal_mirna_mat_denv_final$mat_seq <- gsub("T", "U", aal_mirna_mat_denv_final$mat_seq)

# ===== Save the final data frame =====
write.csv(
  aal_mirna_mat_denv_final,
  "databases/01-isolating-mature-sequences/aal_mat_denv_up_seq.csv",
  row.names = FALSE
)

# ==== Convert df to fasta ====
# convert df to fasta and save output into a custom location for
# subsequent analysis
df_2_fasta(aal_mirna_mat_denv_final, "sequences/01-isolating-mature-sequences/aal_mat_denv_up.fasta")
