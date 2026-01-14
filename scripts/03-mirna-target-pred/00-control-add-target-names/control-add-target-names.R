# ~~~~~ CONTROL: ADD TARGET NAMES ~~~~~ #
# This script takes as input the raw results of miRNA target prediction of previously validated human miRNAs, uses biomaRt as annotation, because the ensembl IDs are provided.
# Then, it merges the input with the dataframe of transcripts provided by biomaRt along their gene names and uniprot ids. Finally, it filters the target prediction results by miRNA and their validated targets along their energy and score values:
# Experimentally validated targets
# hsa-miR-548ba : "LIFR", "PTEN", "NEO1", "SP110"
# hsa-let-7b : "CDC25A", "BCL7A"

# ===== Load libraries & files =====
library("dplyr")
library("biomaRt")
library("tidylog", warn.conflicts = FALSE)
source("scripts/functions.R")

# ===== Importing data ===== #
# Add NA to all empty spaces
# Miranda
control_miranda <- read.delim("databases/02-target-prediction/00-miRNAconsTarget/hsa_controls/miranda.csv")

# ==== FIX DATA ==== #
# Eliminate all decimal parts without rounding
control_miranda$mRNA <- sub("\\..*", "", control_miranda$mRNA)

# ==== CONNECT TO BIOMART API ====
# Connect to current Ensembl
ensembl <- useEnsembl(biomart = "ensembl", dataset = "hsapiens_gene_ensembl")

# Get transcript information
transcript_info <- getBM(
  attributes = c("ensembl_transcript_id", "external_gene_name", "uniprotswissprot"),
  filters = "ensembl_transcript_id",
  values = control_miranda$mRNA,
  mart = ensembl
)

# Rename columns for consistent names
colnames(transcript_info) <- c("tx_id", "gene_name", "uniprot_id")

# ==== MERGE DATABASES ==== #
# Merge transcript name df with initial df
t_control_miranda <- merge(control_miranda, transcript_info, by.x = "mRNA", by.y = "tx_id", all.x = TRUE)

# Reorder columns: first column, then the last two columns, then the remaining columns
t_control_miranda <- reorder_columns(t_control_miranda)

# Filter by lowest to highest energy values
t_control_miranda <- t_control_miranda %>% arrange(energy)

# View the result
head(t_control_miranda)

# ==== FIND WHERE A PREDICTED PROTEINS ====
# Filter rows where gene_name is
vtargets_hsa_miR_548ba <- c("LIFR", "PTEN", "NEO1", "SP110")
vtargets_hsa_let_7b <- c("CDC25A", "BCL7A")
all_validated_targets <- c("LIFR", "PTEN", "NEO1", "SP110", "CDC25A", "BCL7A")

# Find rows where gene_name is in the target list
## miranda
matching_rows_miranda_miR_548ba <- which(t_control_miranda$gene_name %in% vtargets_hsa_miR_548ba)
matching_rows_miranda_let_7b <- which(t_control_miranda$gene_name %in% vtargets_hsa_let_7b)
matching_rows_all <- which(t_control_miranda$gene_name %in% all_validated_targets)

# Extract corresponding rows with miRNA information
## miranda
result_miranda_miR_548ba <- t_control_miranda[matching_rows_miranda_miR_548ba, c("gene_name", "microRNA", "score", "energy")]
result_miranda_let_7b <- t_control_miranda[matching_rows_miranda_let_7b, c("gene_name", "microRNA", "score", "energy")]
result_all <- t_control_miranda[matching_rows_all, c("gene_name", "microRNA", "score", "energy")]

# Filter by miRNA name
result_miranda_miR_548ba2 <- result_miranda_miR_548ba %>%
  dplyr::filter(microRNA == "hsa-miR-548ba")

result_miranda_let_7b2 <- result_miranda_let_7b %>%
  dplyr::filter(microRNA == "hsa-let-7b-5p")

# Print the result
paste("hsa-miR-548ba")
print(result_miranda_miR_548ba2)
paste("hsa-let-7b")
print(result_miranda_let_7b2)
paste("All validated targets")
print(result_all)

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
