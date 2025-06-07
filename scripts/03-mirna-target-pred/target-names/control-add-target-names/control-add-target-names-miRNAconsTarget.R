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
control_miranda <- read.delim("results/miRNAconsTarget/miRNAconsTarget_hsa_controles_all/miranda/miranda.csv")
# ts
control_ts <- read.delim("results/miRNAconsTarget/miRNAconsTarget_hsa_controles_all/targetspy/ts.csv")
# PITA
control_pita <- read.delim("results/miRNAconsTarget/miRNAconsTarget_hsa_controles_all/pita/pita.csv")

# ==== FIX DATA ==== #
# Eliminate all decimal parts without rounding
control_miranda$mRNA <- sub("\\..*", "", control_miranda$mRNA)
control_ts$mRNA <- sub("\\..*", "", control_ts$mRNA)
control_pita$mRNA <- sub("\\..*", "", control_pita$mRNA)

# ===== CHECK PROT DATA ==== #
hsa <- EnsDb.Hsapiens.v86
hasProteinData(hsa)

# ===== API ENSEMBL ===== #
# test only for one transcript ID
tx_miranda <- transcripts(hsa, filter = TxIdFilter(control_miranda$mRNA), 
                          columns = c("tx_id", "uniprot_id", "gene_name"))
tx_ts <- transcripts(hsa, filter = TxIdFilter(control_ts$mRNA), columns = c("tx_id", "uniprot_id", "gene_name"))
tx_pita <- transcripts(hsa, filter = TxIdFilter(control_pita$mRNA), columns = c("tx_id", "uniprot_id", "gene_name"))

# ==== FIX DATABASE PRESENTATION ==== #
# Ensure you have a valid result and convert to dataframes.
# Convert each GRanges object to a data frame
df_miranda <- granges_to_df(tx_miranda)
df_ts <- granges_to_df(tx_ts)
df_pita <- granges_to_df(tx_pita)

# Remove duplicates based on tx_id
df_miranda <- df_miranda %>%
  distinct(tx_id, .keep_all = TRUE)
df_ts <- df_ts %>%
  distinct(tx_id, .keep_all = TRUE)
df_pita <- df_pita %>%
  distinct(tx_id, .keep_all = TRUE)

# ==== MERGE DATABASES ==== #
# Merge transcript name df with initial df
t_control_miranda <- merge_ensembl_to_df(df_miranda, control_miranda)
t_control_ts <- merge_ensembl_to_df(df_ts, control_ts)
t_control_pita <- merge_ensembl_to_df(df_pita, control_pita)

# Get the number of columns in merged_df
# n_cols_miranda <- ncol(t_control_miranda)
# n_cols_ts <- ncol(t_control_ts)
# n_cols_pita <- ncol(t_control_pita)

# Reorder columns: first column, then the last two columns, then the remaining columns
t_control_miranda <- reorder_columns(t_control_miranda)
t_control_ts <- reorder_columns(t_control_ts)
t_control_pita <- reorder_columns(t_control_pita)

# Filter by score highest to lowest score value
t_control_miranda <- t_control_miranda %>% arrange(desc(score))
t_control_ts <- t_control_ts %>% arrange(desc(score))
# Filter by energy lowest to highest value
t_control_pita <- t_control_pita %>% arrange(energy)

# View the result
head(t_control_miranda)
head(t_control_ts)
head(t_control_pita)

# ==== FIND WHERE A PREDICTED PROTEINS ====
# Filter rows where gene_name is
vtargets_hsa_miR_548ba <- c("LIFR", "PTEN", "NEO1", "SP110")
vtargets_hsa_let_7b <- c("CDC25A", "BCL7A")

# Find rows where gene_name is in the target list
## miranda
matching_rows_miranda_miR_548ba <- which(t_control_miranda$gene_name %in% vtargets_hsa_miR_548ba)
matching_rows_miranda_let_7b <- which(t_control_miranda$gene_name %in% vtargets_hsa_let_7b)
## TS
matching_rows_ts_miR_548ba <- which(t_control_ts$gene_name %in% vtargets_hsa_miR_548ba)
matching_rows_ts_let_7b <- which(t_control_ts$gene_name %in% 
                                   vtargets_hsa_let_7b)
## PITA
matching_rows_pita_miR_548ba <- which(t_control_pita$gene_name %in% vtargets_hsa_miR_548ba)
matching_rows_pita_let_7b <- which(t_control_pita$gene_name %in% vtargets_hsa_let_7b)

# Extract corresponding rows with microRNA information
## miranda
result_miranda_miR_548ba <- t_control_miranda[matching_rows_miranda_miR_548ba, c("gene_name", "microRNA", "score")]
result_miranda_let_7b <- t_control_miranda[matching_rows_miranda_let_7b, c("gene_name", "microRNA", "score")]
## TS
result_ts_miR_548ba <- t_control_ts[matching_rows_ts_miR_548ba, c("gene_name", "microRNA", "score")]
result_ts_let_7b <- t_control_ts[matching_rows_ts_let_7b, c("gene_name", "microRNA", "score")]
## PITA
result_pita_miR_548ba <- t_control_pita[matching_rows_pita_miR_548ba, c("gene_name", "microRNA", "energy")]
result_pita_let_7b <- t_control_pita[matching_rows_pita_let_7b, c("gene_name", "microRNA", "energy")]

# Print the result
## miranda
paste("miranda - miR_548ba")
print(result_miranda_miR_548ba)
paste("miranda - let_7b")
print(result_miranda_let_7b)
## TS
paste("TS - miR_548ba")
print(result_ts_miR_548ba)
paste("TS - let_7b")
print(result_ts_let_7b)
## PITA
paste("PITA - miR_548ba")
print(result_pita_miR_548ba)
paste("PITA - let_7b")
print(result_pita_let_7b)

# ==== DOWNLOAD DATABASE ====
# save tcontrol_final to csv
# miranda
write.csv(t_control_miranda,
  "results/miRNAconsTarget/miRNAconsTarget_hsa_controles_all/miranda/t-control-miranda.csv",
  row.names = FALSE
)

# ts
write.csv(t_control_ts,
  "/home/cayetano/livisu/git/miRNAs-mosquitoes/results/miRNAconsTarget/miRNAconsTarget_hsa_controles_all/targetspy/t-control-ts.csv",
  row.names = FALSE
)

# PITA
write.csv(t_control_pita,
  "/home/cayetano/livisu/git/miRNAs-mosquitoes/results/miRNAconsTarget/miRNAconsTarget_hsa_controles_all/pita/t-control-pita.csv",
  row.names = FALSE
)

# save mRNA predicted proteins location
# miranda
write.csv(result_miranda_miR_548ba, "results/miRNAconsTarget/miRNAconsTarget_hsa_controles_all/miranda/t-mir-548ba.csv", row.names = TRUE)
write.csv(result_miranda_let_7b, "results/miRNAconsTarget/miRNAconsTarget_hsa_controles_all/miranda/t-let-7b.csv", row.names = TRUE)

# ts
write.csv(result_ts_miR_548ba, "results/miRNAconsTarget/miRNAconsTarget_hsa_controles_all/targetspy/t-mir-548ba.csv", row.names = TRUE)
write.csv(result_ts_let_7b, "results/miRNAconsTarget/miRNAconsTarget_hsa_controles_all/targetspy/t-let-7b.csv", row.names = TRUE)

# PITA
write.csv(result_pita_miR_548ba, "results/miRNAconsTarget/miRNAconsTarget_hsa_controles_all/pita/t-mir-548ba.csv", row.names = TRUE)
write.csv(result_pita_let_7b, "results/miRNAconsTarget/miRNAconsTarget_hsa_controles_all/pita/t-let-7b.csv", row.names = TRUE)
