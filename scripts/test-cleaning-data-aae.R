# ~~~~~ TEST = ISOLATING AEDES AEGYPTI MIRNA SEQUENCES ~~~~~~
#
# ===== Load libraries & files ===== 
library("tidyverse")

# ===== Importing data ===== 
# Add NA to all empty spaces
aae_mirna <- read.csv("databases/test/aae-mirna-seq.csv",
                      na.strings = c("","NA"))

# ===== Deleting extra columns =====
# Show name of columns
colnames(aae_mirna)
# Isolating miRNA sequences
# # Remove columns with index 1 and from 5 to 39
aae_mirna_seq <- aae_mirna[-c(1,5:39)]

# ==== Deleting all data with NA strings ==== 
aae_mirna_seq <- aae_mirna_seq[complete.cases(aae_mirna_seq), ]

# ==== Deleting duplicated rows based on miRNA_name
aae_mirna_seq <- aae_mirna_seq[!duplicated(aae_mirna_seq$mirna_name), ]