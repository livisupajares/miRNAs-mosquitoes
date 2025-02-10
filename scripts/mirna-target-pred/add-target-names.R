# ~~~~~ ADD TARGET NAMES ~~~~~ #
# if (!require("BiocManager", quietly = TRUE))
#   install.packages("BiocManager")
# 
# BiocManager::install("ensembldb")
# BiocManager::install("EnsDb.Hsapiens.v86")

# https://www.bioconductor.org/packages/devel/bioc/manuals/ensembldb/man/ensembldb.pdf

# ===== Load libraries & files ===== 
library("tidyverse")
library("ensembldb")
library("EnsDb.Hsapiens.v86") # Homo sapiens database

# ===== Importing data ===== #
# Add NA to all empty spaces
control <- read.delim("results/filtar-results/control/control_miranda_target_predictions.txt")

# Eliminate all decimal parts without rounding
control$transcript_ID <- sub("\\..*", "", control$transcript_ID)

# ===== Subset df for testing ===== #
# test_control <- head(control, 50)

# ===== CHECK PROT DATA ==== #
hsa <- EnsDb.Hsapiens.v86
hasProteinData(hsa)

# ===== API ENSEMBL ===== #
# test only for one transcript ID
tx <- transcripts(hsa, filter = TxIdFilter(test_control$transcript_ID), columns = c("tx_id", "uniprot_id", "gene_name"))

# ==== FIX DATABASE PRESENTATION ==== #
# Ensure you have a valid result
if (length(tx) > 0) {
  df <- as.data.frame(mcols(tx))  # Extract metadata columns and convert to data.frame
} else {
  df <- data.frame()  # Create an empty data frame if no results are found
}

# Remove duplicates in y based on tx_id
df <- df %>%
  distinct(tx_id, .keep_all = TRUE)

# Ensure `df` exists and contains transcript information
if (exists("df") && nrow(df) > 0) {
  # Merge both dataframes by matching `transcript_id` with `tx_id`
  tcontrol_final <- merge(test_control, df, by.x = "transcript_ID", by.y = "tx_id", all.x = TRUE)
} else {
  tcontrol_final <- test_control  # If df is empty, keep only transcript_id_df
}

# ==== REORDER COLUMNS ==== #

# Get the number of columns in merged_df
n_cols <- ncol(tcontrol_final)

# Reorder columns: first column, then the last two columns, then the remaining columns
tcontrol_final <- tcontrol_final[, c(1, (n_cols - 1):n_cols, 2:(n_cols - 2))]

# View the result
head(tcontrol_final)