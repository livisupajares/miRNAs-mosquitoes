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

# ==== FINDING THE BEST mRNA TARGET CANDIDATES ====
# https://genomebiology.biomedcentral.com/articles/10.1186/gb-2003-5-1-r1
# https://bmcbioinformatics.biomedcentral.com/articles/10.1186/1471-2105-11-292

# List of upregulated microRNAs to filter by
microRNA_list_miranda <- c(
  "miR-276-5p",
  "miR-2945-3p"
)

# Filter the dataset for all microRNAs in one step
filtered_data_miranda <- aae_miranda_down_tx_names %>%
  filter(microRNA %in% microRNA_list_miranda)

# Split the filtered data into a list of data frames, one for each microRNA
mirna_list_miranda <- split(filtered_data_miranda, filtered_data_miranda$microRNA)

# Apply additional filtering (e.g., highest score and lowest energy)
candidates_miranda <<- lapply(mirna_list_miranda, function(df) {
  df %>%
    arrange(desc(score), energy) %>% # Sort by highest score and lowest energy
    filter(energy <= -20) %>% # Filter by energy <= -20 kcal/mol
    filter(!duplicated(uniprot_id)) # Remove duplicates based on uniprot_id
})

# Access each miRNA data frame by its name
View(candidates_miranda[["miR-276-5p"]])
View(candidates_miranda[["miR-2945-3p"]])

# Also filter and sort dataframe with all the up-regulated miRNAs
aae_miranda_down_tx_names_sorted <- aae_miranda_down_tx_names %>%
  arrange(desc(score), energy) %>% # Sort by highest score and lowest energy
  filter(energy <= -20) %>% # Filter by energy <= -20 kcal/mol
  filter(!duplicated(uniprot_id)) # Remove duplicates based on uniprot_id

# ==== DATA SUMMARY ====
# Count the number of unique UNIPROT IDS in the dataset
length(unique(aae_miranda_down_tx_names_sorted$uniprot_id)) # 371

# ==== DOWNLOAD DATABASE ====
# save dataframe with all upregulated miRNAs
write.csv(aae_miranda_down_tx_names_sorted, file = "results/01-target-prediction/00-miRNAconsTarget/aae_down/miranda-aae-uniprot-filtered.csv", row.names = FALSE)

