# ~~~~~ ADD TARGET NAMES ~~~~~ #
# if (!require("BiocManager", quietly = TRUE))
#   install.packages("BiocManager")
#
# BiocManager::install("biomaRt")

# ===== Load libraries & files =====
library("dplyr")
source("scripts/functions.R")

# ===== Importing data ===== #
# Add NA to all empty spaces
# Miranda
aae_miranda <- read.delim("results/miRNAconsTarget/miRNAconsTarget_aae_all/miranda-aae/miranda-aae.csv")
# ts
aae_ts <- read.delim("results/miRNAconsTarget/miRNAconsTarget_aae_all/targetspy-aae/targetspy-aae.csv")

# vectorbase aal transcripts Foshan strain
aal_vectorbase <- read.csv("databases/vector-base-mosquitos/aal-transcript-names-vectorbase.csv")

# ==== FIX DATA ==== #
# Eliminate all decimal parts without rounding
aae_miranda$mRNA <- sub("\\..*", "", aae_miranda$mRNA)
aae_ts$mRNA <- sub("\\..*", "", aae_ts$mRNA)

# Change variable name to match the other databases
colnames(aal_vectorbase) <- c("gene_id", "transcript_id", "organism", "gene_name", "transcript_product_descrip", "uniprot_id")

# Filter the columns we will add to the aae_miranda and aae_ts dataframes
aal_important_transcr <- aal_vectorbase %>% select("transcript_id", "transcript_product_descrip", "uniprot_id")

# ==== MERGE DATABASES ====
# merge aae_miranda with aal_vectorbase matching transcript_ID
aae_miranda_tx_names <- merge(aae_miranda, aal_important_transcr, by.x = "mRNA", by.y = "transcript_id", all.x = TRUE)

# merge aae_ts with aal_vectorbase matching transcript_ID
aae_ts_tx_names <- merge(aae_ts, aal_important_transcr, by.x = "mRNA", by.y = "transcript_id", all.x = TRUE)

# reorder columns so transcript product description and uniprot_id are 
# between mRNA and miRNA columns.
aae_miranda_tx_names <- reorder_columns(aae_miranda_tx_names)
aae_ts_tx_names <- reorder_columns(aae_ts_tx_names)

# Filter by highest to lowest score value
aae_miranda_tx_names <- aae_miranda_tx_names %>% arrange(desc(score))
aae_ts_tx_names <- aae_ts_tx_names %>% arrange(desc(score))
