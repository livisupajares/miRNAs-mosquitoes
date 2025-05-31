# ~~~~~ TEST = ISOLATING AEDES AEGYPTI MIRNA SEQUENCES ~~~~~~
#
# ===== Load libraries & files =====
# library("tidyverse")
source("scripts/functions.R")

# ===== Importing data =====
# Add NA to all empty spaces
aae_mirna <- read.csv("databases/metadata-aedes/aae-mirna.csv",
  na.strings = c("", "NA")
)

# Add aae- before miRNA name
aae_mirna$mirna_name <- paste0("aae-", aae_mirna$mirna_name)

# ===== Deleting extra columns =====
# Show name of columns
colnames(aae_mirna)
# Isolating miRNA sequences
## Mature sequence of all aae
### Remove columns with index 1, 3 and from 5 to 39
# aae_mirna_mat <- aae_mirna[-c(1,3,5:39)]

## Mature sequence of aae infected with DENV-2
# aae_mirna_mat_denv <- aae_mirna[-c(1, 3, 5:21, 24:39)]
aae_mirna_subset <- aae_mirna[-c(1, 3, 5:20, 23:43, 45)]

# ==== Deleting all data with NA strings ====
# Delete NA rows with NA values only from the column mat_seq
# aae_mirna_mat <- aae_mirna_mat[complete.cases(aae_mirna_mat), ]
aae_mirna_clean <- subset(aae_mirna_subset, !(is.na(mat_seq)))

# ==== Deleting data that is not from DENV-2 ====
aae_mirna_mat_denv <-
  aae_mirna_clean[grepl("denv", aae_mirna_clean$infection), ]

# ==== Deleting duplicated rows based on miRNA_name ====
# aae_mirna_mat <- aae_mirna_mat[!duplicated(aae_mirna_mat$mirna_name), ]
aae_mirna_mat_denv <-
  aae_mirna_mat_denv[!duplicated(aae_mirna_mat_denv$mirna_name), ]

# ==== Deleting down-regulated miRNAs ====
aae_mirna_mat_denv <-
  aae_mirna_mat_denv[grepl("up-regulated", aae_mirna_mat_denv$exp_DENV), ]

# Deleting the infection and exp_DENV column
aae_mirna_mat_denv <- aae_mirna_mat_denv[-c(3:5)]

# ==== Delete the numbers from miRNA strings ====
# Delete numbers
# aae_mirna_mat$mat_seq <- gsub("[0-9]", "", aae_mirna_mat$mat_seq)
aae_mirna_mat_denv$mat_seq <- gsub("[0-9]", "", aae_mirna_mat_denv$mat_seq)
# Delete hyphens
# aae_mirna_mat$mat_seq <- gsub("-", "", aae_mirna_mat$mat_seq)
aae_mirna_mat_denv$mat_seq <- gsub("-", "", aae_mirna_mat_denv$mat_seq)
# Delete blank spaces
# aae_mirna_mat$mat_seq <- gsub(" ", "", aae_mirna_mat$mat_seq)
aae_mirna_mat_denv$mat_seq <- gsub(" ", "", aae_mirna_mat_denv$mat_seq)

# ==== Convert df to fasta ====
# df_2_fasta(aae_mirna_mat, "sequences/test/aae_test_mat.fasta")
df_2_fasta(aae_mirna_mat_denv, "sequences/aae-complete/aae_mat_denv.fasta")
