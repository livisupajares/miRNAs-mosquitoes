# ~~~~~ ADD TARGET NAMES ~~~~~ #
# if (!require("BiocManager", quietly = TRUE))
#   install.packages("BiocManager")
# 
# BiocManager::install("ensembldb")
# BiocManager::install("EnsDb.Hsapiens.v86")

# https://www.bioconductor.org/packages/devel/bioc/manuals/ensembldb/man/ensembldb.pdf

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
tx_miranda <- transcripts(hsa, filter = TxIdFilter(control_miranda$mRNA), columns = c("tx_id", "uniprot_id", "gene_name"))
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
t_control_pita<- merge_ensembl_to_df(df_pita, control_pita)

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

# ==== DOWNLOAD DATABASE ====
# save tcontrol_final to csv
# miranda
write.csv(t_control_miranda,
          "/home/cayetano/livisu/git/miRNAs-mosquitoes/results/miRNAconsTarget/miRNAconsTarget_hsa_controles_all/miranda/t-control-miranda.csv",
          row.names = FALSE)

# ts
write.csv(t_control_ts,
          "/home/cayetano/livisu/git/miRNAs-mosquitoes/results/miRNAconsTarget/miRNAconsTarget_hsa_controles_all/targetspy/t-control-ts.csv",
          row.names = FALSE)

# PITA
write.csv(t_control_pita,
          "/home/cayetano/livisu/git/miRNAs-mosquitoes/results/miRNAconsTarget/miRNAconsTarget_hsa_controles_all/pita/t-control-pita.csv",
          row.names = FALSE)

