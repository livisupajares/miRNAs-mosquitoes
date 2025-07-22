# ~~~~~ ADD TARGET NAMES ~~~~~ #
# This script adds target names to the Aedes aegypti miRNA target prediction
# results from the miRanda algorithm.
# This script also filters the results to find the best mRNA target candidates
# according to a specific criteria (highest score, lowest energy (-14 kcal/mol
# cutoff)
# ===== Load libraries & files =====
library("dplyr")
source("scripts/functions.R")

# ===== Importing data ===== #
# Add NA to all empty spaces
# Miranda
aae_miranda <- read.csv("results/00-target-prediction/00-miRNAconsTarget/aae_up/miranda-aae/miranda-aae.csv")

# Add Aedes aegypti biomart metadata with uniprots for transcripts
aae_biomart <- read.csv("results/00-target-prediction/01-ensembl-metazoa-biomart/uniprots_aae_biomart.csv")

# ==== FIX DATA ==== #

# Change variable name to match the other databases
colnames(aae_biomart) <- c("gene_id", "transcript_id", "uniprot_id")

# ==== MERGE DATABASES ====
# Eliminate dashes and characters after dashes.
# aae_miranda$mRNA <- sub("-.*", "", aae_miranda$mRNA)

# merge aae_miranda with aal_vectorbase matching transcript_ID
aae_miranda_tx_names <- merge(aae_miranda, aae_biomart, by.x = "mRNA", by.y = "transcript_id", all.x = TRUE)

# reorder columns so transcript product description and uniprot_id are
# between mRNA and miRNA columns.
aae_miranda_tx_names <- reorder_columns(aae_miranda_tx_names)

# ==== FINDING THE BEST mRNA TARGET CANDIDATES ====
# https://genomebiology.biomedcentral.com/articles/10.1186/gb-2003-5-1-r1
# https://bmcbioinformatics.biomedcentral.com/articles/10.1186/1471-2105-11-292

# List of upregulated microRNAs to filter by
microRNA_list_miranda <- c(
  "aae-miR-34-5p",
  "aae-miR-5119-5p"
)

# Filter the dataset for all microRNAs in one step
filtered_data_miranda <- aae_miranda_tx_names %>%
  filter(microRNA %in% microRNA_list_miranda)

# Split the filtered data into a list of data frames, one for each microRNA
mirna_list_miranda <- split(filtered_data_miranda, filtered_data_miranda$microRNA)

# Apply additional filtering (e.g., highest score and lowest energy)
candidates_miranda <<- lapply(mirna_list_miranda, function(df) {
  df %>%
    arrange(desc(score), energy) %>% # Sort by highest score and lowest energy
    filter(energy <= -14) %>% # Filter by energy <= -14 kcal/mol
    filter(!duplicated(uniprot_id)) # Remove duplicates based on uniprot_id
})

# Access each miRNA data frame by its name
View(candidates_miranda[["aae-miR-34-5p"]])
View(candidates_miranda[["aae-miR-5119-5p"]])

# Also filter and sort dataframe with all the up-regulated miRNAs
aae_miranda_tx_names_sorted <- aae_miranda_tx_names %>%
  arrange(desc(score), energy) %>% # Sort by highest score and lowest energy
  filter(energy <= -14) %>% # Filter by energy <= -14 kcal/mol
  filter(!duplicated(uniprot_id)) # Remove duplicates based on uniprot_id

# ==== DOWNLOAD DATABASE ====
# save dataframe with all upregulated miRNAs
write.csv(aae_miranda_tx_names_sorted, file = "results/00-target-prediction/00-miRNAconsTarget/aae_up/miranda-aae/miranda-aae-uniprot-filtered.csv", row.names = FALSE)

# save filtered database by miRNA
# Write each miRNA data frame to a separate CSV file
output_dir_mir <- "results/00-target-prediction/00-miRNAconsTarget/aae_up/miranda-aae/mirna-individuales" # Directory to save the CSV files

lapply(names(candidates_miranda), function(miRNA_name) {
  df <- candidates_miranda[[miRNA_name]]
  # Construct the file name
  file_name <- paste0(output_dir_mir, "/", gsub("-", "_", miRNA_name), ".csv")
  # Write the data frame to a CSV file
  write.csv(df, file = file_name, row.names = FALSE)
  # Optional: Print a message to confirm the file was written
  cat("Wrote CSV file for:", miRNA_name, "\n")
})
