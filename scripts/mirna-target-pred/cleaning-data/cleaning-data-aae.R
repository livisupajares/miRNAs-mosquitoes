# ~~~~~ TEST = ISOLATING AEDES AEGYPTI MIRNA SEQUENCES ~~~~~~
#
# ===== Load libraries & files ===== 
# library("tidyverse")
source("scripts/functions.R")

# ===== Importing data ===== 
# Add NA to all empty spaces
## Test 
# aae_mirna <- read.csv("sequences/test/aae-mirna-seq.csv",
#                       na.strings = c("","NA"))
aae_mirna <- read.csv("sequences/aae-complete/aae-mirna-seq.csv",
                      na.strings = c("","NA"))

# aae_mirna_mat <- aae_mirna[-c(1,3,5:39)]
# aae_mirna_mat <- aae_mirna_mat[complete.cases(aae_mirna_mat), ]
# aae_mirna_mat <- aae_mirna_mat[!duplicated(aae_mirna_mat$mirna_name), ]
# aae_mirna_mat$mat_seq <- gsub("[0-9]", "", aae_mirna_mat$mat_seq)
# aae_mirna_mat$mat_seq <- gsub("-", "", aae_mirna_mat$mat_seq)
# aae_mirna_mat$mat_seq <- gsub(" ", "", aae_mirna_mat$mat_seq)
# df_2_fasta(aae_mirna_mat, "sequences/test/aae_test_mat.fasta")
