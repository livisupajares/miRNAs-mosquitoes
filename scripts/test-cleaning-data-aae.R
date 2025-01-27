# ~~~~~ TEST = ISOLATING AEDES AEGYPTI MIRNA SEQUENCES ~~~~~~
#
# ===== Load libraries & files ===== 
library("tidyverse")
source("scripts/functions.R")
# ===== Importing data ===== 
# Add NA to all empty spaces
aae_mirna <- read.csv("databases/test/aae-mirna-seq.csv",
                      na.strings = c("","NA"))

# ===== Deleting extra columns =====
# Show name of columns
colnames(aae_mirna)
# Isolating miRNA sequences
# # Remove columns with index 1, 3 and from 5 to 39
aae_mirna_mat <- aae_mirna[-c(1,3,5:39)]

# ==== Deleting all data with NA strings ==== 
aae_mirna_mat <- aae_mirna_mat[complete.cases(aae_mirna_mat), ]

# ==== Deleting duplicated rows based on miRNA_name ====
aae_mirna_mat <- aae_mirna_mat[!duplicated(aae_mirna_mat$mirna_mat), ]

# ==== Delete the numbers from miRNA strings ====
# Delete numbers
aae_mirna_seq$mat_seq <- gsub("[0-9]", "", aae_mirna_mat$mat_seq)
# Delete hyphens
aae_mirna_seq$mat_seq <- gsub("-", "", aae_mirna_mat$mat_seq)
# Delete blank spaces
aae_mirna_seq$mat_seq <- gsub(" ", "", aae_mirna_mat$mat_seq)

# ==== Convert df to fasta ====
df_2_fasta(aae_mirna_mat, "databases/test/aae_test_mirna.fasta")