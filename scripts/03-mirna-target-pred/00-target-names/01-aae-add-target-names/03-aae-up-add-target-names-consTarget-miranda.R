# ~~~~~ ADD TARGET NAMES ~~~~~ #
# This script adds target names to the Aedes aegypti miRNA target prediction
# results from the miRanda algorithm (targets from down-regultared miRNAs during DENV-2 infection that can be found in common with up-regulated Aedes albopictus miRNAs)
# This script also filters the results to find the best mRNA target candidates
# according to a specific criteria (highest score, lowest energy (-20 kcal/mol
# cutoff)

# NOTE: We were supposed to merge VectorBase info into predicted targets by
# transcript id, but for some reason it fails to merge using the same command as
# in Aedes albopictus. So we will use the biomart info instead.

# ===== Load libraries & files =====
library("dplyr")
library("tidylog", warn.conflicts = FALSE)
source("scripts/functions.R")

# ===== Importing data ===== #
# Add NA to all empty spaces
aae_miranda_down <- read.csv("databases/02-target-prediction/00-miRNAconsTarget/aae_down/miranda-down-aae.csv")

# Add Aedes aegypti biomart metadata with uniprots for transcripts.
# This is the direct output from the previous script: `01-fetch-aae-uniprot.R`
aae_biomart <- read.csv("results/01-target-prediction/01-ensembl-metazoa-biomart/uniprots_aae_biomart.csv")

# ==== FIX DATA ==== #
# Change variable name to match the other databases
colnames(aae_biomart) <- c("gene_id", "transcript_id", "uniprot_id")

# ==== MERGE DATABASES ====
# merge aae_miranda with aae biomart matching transcript_ID
aae_miranda_down_tx_names <- aae_miranda_down %>%
  left_join(aae_biomart, by = c("mRNA" = "transcript_id"))

# reorder columns so transcript product description and uniprot_id are
# between mRNA and miRNA columns.
aae_miranda_down_tx_names <- reorder_columns(aae_miranda_down_tx_names)

# ==== DATA SUMMARY ====
# Count the number of unique UNIPROT IDS in the dataset
length(unique(aae_miranda_down_tx_names$uniprot_id)) # 1813

