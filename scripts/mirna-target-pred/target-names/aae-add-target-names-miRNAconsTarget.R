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

# ==== FINDING THE BEST mRNA TARGET CANDIDATES ====
# TODO: then filter by highest score and lowest energy
# TODO: if there are multiple miRNAs in the same target, pick by highest score
# and lowest energy.
# https://genomebiology.biomedcentral.com/articles/10.1186/gb-2003-5-1-r1
# https://bmcbioinformatics.biomedcentral.com/articles/10.1186/1471-2105-11-292

# aae-miR-210-5p
# 1. Filter by microRNA
aae_miranda_miR_210_5p <- aae_miranda_tx_names %>% filter(microRNA == "aae-miR-210-5p")

# aae-miR-276-3p
# # 1. Filter by microRNA
aae_miranda_miR_276_3p <- aae_miranda_tx_names %>% filter(microRNA == "aae-miR-276-3p")

# aae-miR-276-5p
# 1. Filter by microRNA
aae_miranda_miR_276_5p <- aae_miranda_tx_names %>% filter(microRNA == "aae-miR-276-5p")

# aae-miR-2945-3p
# 1. Filter by microRNA
aae_miranda_miR_2945_3p <- aae_miranda_tx_names %>% filter(microRNA == "aae-miR-2945-3p")

# aae-miR-305-5p
# 1. Filter by microRNA
aae_miranda_miR_305_5p <- aae_miranda_tx_names %>% filter(microRNA == "aae-miR-305-5p")

# aae-miR-34-5p
# 1. Filter by microRNA
aae_miranda_miR_34_5p <- aae_miranda_tx_names %>% filter(microRNA == "aae-miR-34-5p")

# aae-miR-1000-5p
# 1. Filter by microRNA
aae_miranda_miR_1000_5p <- aae_miranda_tx_names %>% filter(microRNA == "aae-miR-1000-5p")

# aae-miR-308-3p
# 1. Filter by microRNA
aae_miranda_miR_308_3p <- aae_miranda_tx_names %>% filter(microRNA == "aae-miR-308-3p")

# aae-miR-999-3p
# 1. Filter by microRNA
aae_miranda_miR_999_3p <- aae_miranda_tx_names %>% filter(microRNA == "aae-miR-999-3p")

# aae-bantam-3p
# 1. Filter by microRNA
aae_miranda_bantam_3p <- aae_miranda_tx_names %>% filter(microRNA == "aae-bantam-3p")

# aae-bantam-5p
# 1. Filter by microRNA
aae_miranda_bantam_5p <- aae_miranda_tx_names %>% filter(microRNA == "aae-bantam-5p")

# aae-let-7
# 1. Filter by microRNA
aae_miranda_let_7 <- aae_miranda_tx_names %>% filter(microRNA == "aae-let-7")

# aae-miR-10-5p
# 1. Filter by microRNA
aae_miranda_miR_10_5p <- aae_miranda_tx_names %>% filter(microRNA == "aae-miR-10-5p")

# aae-miR-1175-3p
# 1. Filter by microRNA
aae_miranda_miR_1175_3p <- aae_miranda_tx_names %>% filter(microRNA == "aae-miR-1175-3p")

# aae-miR-11900
# 1. Filter by microRNA
aae_miranda_miR_11900 <- aae_miranda_tx_names %>% filter(microRNA == "aae-miR-11900")

# aae-miR-124-3p
# 1. Filter by microRNA
aae_miranda_miR_124_3p <- aae_miranda_tx_names %>% filter(microRNA == "aae-miR-124-3p")

# aae-miR-3368-5p
# 1. Filter by microRNA
aae_miranda_miR_3368_5p <- aae_miranda_tx_names %>% filter(microRNA == "aae-miR-3368-5p")

# aae-miR-3722-5p
# 1. Filter by microRNA
aae_miranda_miR_3722_5p <- aae_miranda_tx_names %>% filter(microRNA == "aae-miR-3722-5p")

# aae-miR-4275-5p
# 1. Filter by microRNA
aae_miranda_miR_4275_5p <- aae_miranda_tx_names %>% filter(microRNA == "aae-miR-4275-5p")

# aae-miR-5108-5p
# 1. Filter by microRNA
aae_miranda_miR_5108_5p <- aae_miranda_tx_names %>% filter(microRNA == "aae-miR-5108-5p")

# aae-miR-5119-5p
# 1. Filter by microRNA
aae_miranda_miR_5119_5p <- aae_miranda_tx_names %>% filter(microRNA == "aae-miR-5119-5p")

# aae-miR-932-5p
# 1. Filter by microRNA
aae_miranda_miR_932_5p <- aae_miranda_tx_names %>% filter(microRNA == "aae-miR-932-5p")

# Filter by highest to lowest score value
aae_miranda_tx_names <- aae_miranda_tx_names %>% arrange(desc(score))
aae_ts_tx_names <- aae_ts_tx_names %>% arrange(desc(score))

# ==== DOWNLOAD DATABASE ====
# save filtered database
aae_miranda_tx_names <- write.csv(aae_miranda_tx_names, "results/miRNAconsTarget/miRNAconsTarget_aae_all/miranda-aae/aae-miranda-tx-names.csv")
aae_ts_tx_names <- write.csv(aae_ts_tx_names, "results/miRNAconsTarget/miRNAconsTarget_aae_all/targetspy-aae/aae-targetspy-tx-names.csv")
