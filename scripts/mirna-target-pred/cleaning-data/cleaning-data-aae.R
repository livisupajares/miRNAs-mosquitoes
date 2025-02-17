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
aae_mirna_mat_denv <- aae_mirna[-c(1,3,5:21,23:39)]

# ==== Deleting all data with NA strings ==== 
# aae_mirna_mat <- aae_mirna_mat[complete.cases(aae_mirna_mat), ]
aae_mirna_mat_denv <- aae_mirna_mat_denv[complete.cases(aae_mirna_mat_denv), ]

# ==== Deleting data that is not from DENV-2 ====
aae_mirna_mat_denv <- aae_mirna_mat_denv[grepl("denv",aae_mirna_mat_denv$infection),]
# Deleting the infection column
aae_mirna_mat_denv <- aae_mirna_mat_denv[-c(3)]

# ==== Deleting duplicated rows based on miRNA_name ====
# aae_mirna_mat <- aae_mirna_mat[!duplicated(aae_mirna_mat$mirna_name), ]
aae_mirna_mat_denv <- aae_mirna_mat_denv[!duplicated(aae_mirna_mat_denv$mirna_name), ]

# aae_mirna_mat$mat_seq <- gsub("[0-9]", "", aae_mirna_mat$mat_seq)
# aae_mirna_mat$mat_seq <- gsub("-", "", aae_mirna_mat$mat_seq)
# aae_mirna_mat$mat_seq <- gsub(" ", "", aae_mirna_mat$mat_seq)
# df_2_fasta(aae_mirna_mat, "sequences/test/aae_test_mat.fasta")
