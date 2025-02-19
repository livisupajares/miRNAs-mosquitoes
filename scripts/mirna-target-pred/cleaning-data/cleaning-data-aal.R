# ~~~~~ TEST = ISOLATE AEDES ALBOPICTUS MIRNA SEQUENCES ~~~~~~
#
# ===== Load libraries & files ===== 
# library("tidyverse")
source("scripts/functions.R")

# ===== Importing data ===== 
# Add NA to all empty spaces
aal_mirna <- read.csv("sequences/aal-complete/aal-mirna-seq-U.csv",
                      na.strings = c("","NA"))

# Add aal- before miRNA name
aal_mirna$mirna_name <- paste0("aal-", aal_mirna$mirna_name)

# ===== Deleting extra columns =====
# Show name of columns
colnames(aal_mirna)
aal_mirna_mat_denv <- aal_mirna[-c(1,3,5:21,23:39)]

# ==== Deleting data that aren't nucleotides ==== 
aal_mirna_mat_denv <- aal_mirna_mat_denv[!grepl("NO HAY SECUENCIA" ,aal_mirna_mat_denv$mat_seq),]

# ==== Deleting data that is not from DENV-2 ====
aal_mirna_mat_denv <- aal_mirna_mat_denv[grepl("denv",aal_mirna_mat_denv$infection),]

# Deleting the infection column
aal_mirna_mat_denv <- aal_mirna_mat_denv[-c(3)]

# ==== Deleting duplicated rows based on miRNA_name ====
aal_mirna_mat_denv <- aal_mirna_mat_denv[!duplicated(aal_mirna_mat_denv$mirna_name), ]

# ==== Delete the numbers from miRNA strings ====
# Delete parenthesis
aal_mirna_mat_denv$mat_seq <- gsub("\\(G\\)", "", aal_mirna_mat_denv$mat_seq)

# ==== Convert df to fasta ====
# convert df to fasta and save output into a custom location for subsequent analysis
df_2_fasta(aal_mirna_mat_denv, "sequences/aal-complete/aal_test_mat_denv.fasta")
