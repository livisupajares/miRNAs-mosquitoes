# ~~~~~ ADD TARGET NAMES ~~~~~ #
# if (!require("BiocManager", quietly = TRUE))
#   install.packages("BiocManager")
#
# BiocManager::install("ensembldb")
# BiocManager::install("EnsDb.Hsapiens.v86")

# https://www.bioconductor.org/packages/devel/bioc/manuals/ensembldb/man/
# ensembldb.pdf

# ===== Load libraries & files =====
library("dplyr")
library("ensembldb")
library("EnsDb.Hsapiens.v86") # Homo sapiens database
source("scripts/functions.R")

# ===== Importing data ===== #
# Add NA to all empty spaces
# Miranda
control_miranda <- read.delim("databases/02-target-prediction/00-miRNAconsTarget/hsa_controls/miranda.csv")

# ==== FIX DATA ==== #
# Eliminate all decimal parts without rounding
control_miranda$mRNA <- sub("\\..*", "", control_miranda$mRNA)

# ===== CHECK PROT DATA ==== #
hsa <- EnsDb.Hsapiens.v86
hasProteinData(hsa)

# ===== API ENSEMBL ===== #
# Fetch transcript IDs from Ensembl API
tx_miranda <- transcripts(hsa,
  filter = TxIdFilter(control_miranda$mRNA),
  columns = c("tx_id", "uniprot_id", "gene_name")
)

# ==== FIX DATABASE PRESENTATION ==== #
# Ensure you have a valid result and convert to dataframes.
# Convert each GRanges object to a data frame
df_miranda <- granges_to_df(tx_miranda)

# Remove duplicates based on tx_id
df_miranda <- df_miranda %>%
  distinct(tx_id, .keep_all = TRUE)

# ==== MERGE DATABASES ==== #
# Merge transcript name df with initial df
t_control_miranda <- merge_ensembl_to_df(df_miranda, control_miranda)

# Reorder columns: first column, then the last two columns, then the remaining columns
t_control_miranda <- reorder_columns(t_control_miranda)

# Filter by score highest to lowest score value
t_control_miranda <- t_control_miranda %>% arrange(desc(score))

# View the result
head(t_control_miranda)

# ==== FIND WHERE A PREDICTED PROTEINS ====
# Filter rows where gene_name is
vtargets_hsa_miR_548ba <- c("LIFR", "PTEN", "NEO1", "SP110")
vtargets_hsa_let_7b <- c("CDC25A", "BCL7A")

# Find rows where gene_name is in the target list
## miranda
matching_rows_miranda_miR_548ba <- which(t_control_miranda$gene_name %in% vtargets_hsa_miR_548ba)
matching_rows_miranda_let_7b <- which(t_control_miranda$gene_name %in% vtargets_hsa_let_7b)

# Extract corresponding rows with microRNA information
## miranda
result_miranda_miR_548ba <- t_control_miranda[matching_rows_miranda_miR_548ba, c("gene_name", "microRNA", "score")]
result_miranda_let_7b <- t_control_miranda[matching_rows_miranda_let_7b, c("gene_name", "microRNA", "score")]

# Print the result
## miranda
paste("miranda - miR_548ba")
print(result_miranda_miR_548ba)
paste("miranda - let_7b")
print(result_miranda_let_7b)

# ==== DOWNLOAD DATABASE ====
# save tcontrol_final to csv
# miranda
write.csv(t_control_miranda,
  "results/01-target-prediction/00-miRNAconsTarget/hsa_controls/t-control-miranda.csv",
  row.names = FALSE
)

# save mRNA predicted proteins location
# miranda
write.csv(result_miranda_miR_548ba, "results/01-target-prediction/00-miRNAconsTarget/hsa_controls/t-mir-548ba.csv", row.names = TRUE)
write.csv(result_miranda_let_7b, "results/01-target-prediction/00-miRNAconsTarget/hsa_controls/t-let-7b.csv", row.names = TRUE)
