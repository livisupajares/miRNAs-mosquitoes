# ~~~~~ TEST = ISOLATE AEDES ALBOPICTUS MIRNA SEQUENCES ~~~~~~
#
# ===== Load libraries & files =====
library(dplyr)
source("scripts/functions.R")

# ===== Importing data =====
# Add NA to all empty spaces
aal_mirna <- read.csv("sequences/aal-complete/aal-mirna-seq.csv",
  na.strings = c("", "NA")
)

# Add aal- before miRNA name
aal_mirna$mirna_name <- paste0("aal-", aal_mirna$mirna_name)

# ===== Deleting extra columns =====
# Show name of columns
colnames(aal_mirna)
aal_mirna_mat_subset <- aal_mirna[-c(2, 4:20, 23:38)]

# ==== Deleting data that aren't nucleotides ====
# Equivalente a eliminar los NAs
aal_mirna_mat_subset <- aal_mirna_mat_subset[!grepl(
  "NO HAY SECUENCIA",
  aal_mirna_mat_subset$mat_seq
), ]

# ==== Deleting data that is not from DENV-2 ====
# Some duplicates have both up-regulated and down-regulated in the same miRNA.
aal_mirna_mat_denv_duplicates <- aal_mirna_mat_subset[grepl(
  "denv",
  aal_mirna_mat_subset$infection
), ]

# ==== Deleting duplicated rows based on miRNA_name ====
# See how many unique miRNAs are infected with DENV
aal_mirna_mat_denv <- aal_mirna_mat_denv_duplicates[!duplicated(
  aal_mirna_mat_denv_duplicates$mirna_name
), ]

# Reset row names so R doesn't get confused with skipped rows from filtering
rownames(aal_mirna_mat_denv) <- NULL

# Replace NA with "up-regulated", because I forgot to add said value in the .csv
aal_mirna_mat_denv[53, 4] <- "up-regulated"

# Deleting down-regulated miRNAs
# Duplicated are already removed
aal_mirna_mat_denv_up <- aal_mirna_mat_denv[grepl("up-regulated", aal_mirna_mat_denv$exp_DENV), ]

# Deleting the infection column
aal_mirna_mat_denv_final <- aal_mirna_mat_denv_up[-c(3, 4)]

# ==== Delete the numbers from miRNA strings ====
# Delete parenthesis
aal_mirna_mat_denv_final$mat_seq <- gsub("\\(G\\)", "", aal_mirna_mat_denv_final$mat_seq)

# ==== Replace all Ts into Us ====
aal_mirna_mat_denv_final$mat_seq <- gsub("T", "U", aal_mirna_mat_denv_final$mat_seq)

# ===== Save the final data frame =====
write.csv(
  aal_mirna_mat_denv_final,
  "results/aal_mat_denv_final.csv",
  row.names = FALSE
)

# ==== Convert df to fasta ====
# convert df to fasta and save output into a custom location for
# subsequent analysis
df_2_fasta(aal_mirna_mat_denv_final, "sequences/aal-complete/aal_mat_denv.fasta")
