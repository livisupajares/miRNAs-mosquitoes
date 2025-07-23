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
aal_miranda <- read.csv("databases/02-target-prediction/00-miRNAconsTarget/aal_up/miranda-aal/miranda-aal.csv")

# vectorbase aal transcripts Foshan strain
# This file are downloaded from VectorBase
aal_vectorbase <- read.csv("databases/02-target-prediction/aal-transcript-names-vectorbase.csv")

# ==== FIX DATA ==== #
# Eliminate all decimal parts without rounding
aal_miranda$mRNA <- sub("\\..*", "", aal_miranda$mRNA)

# Change variable name to match the other databases
colnames(aal_vectorbase) <- c("gene_id", "transcript_id", "organism", "gene_name", "transcript_product_descrip", "uniprot_id")

# Filter the columns we will add to the aae_miranda dataframes
aal_important_transcr <- aal_vectorbase %>% dplyr::select("transcript_id", "transcript_product_descrip", "uniprot_id")

# ==== MERGE DATABASES ====
# merge aal_miranda with aal_vectorbase matching transcript_ID
aal_miranda_tx_names <- merge(aal_miranda, aal_important_transcr, by.x = "mRNA", by.y = "transcript_id", all.x = TRUE)

# reorder columns so transcript product description and uniprot_id are
# between mRNA and miRNA columns.
aal_miranda_tx_names <- reorder_columns(aal_miranda_tx_names)

# ==== FINDING THE BEST mRNA TARGET CANDIDATES ====
# https://genomebiology.biomedcentral.com/articles/10.1186/gb-2003-5-1-r1
# https://bmcbioinformatics.biomedcentral.com/articles/10.1186/1471-2105-11-292

# List of microRNAs to filter by
microRNA_list_miranda <- c("aal-miR-1767", "aal-miR-193-5p", "aal-miR-1951", "aal-miR-424-3p", "aal-miR-4728-5p", "aal-miR-976-5p", "aal-miR-998", "aal-miR-1889b-3p", "aal-miR-190-5p", "aal-miR-252b-5p", "aal-miR-276-5p", "aal-miR-2796-3p", "aal-miR-281-3p", "aal-miR-2943", "aal-miR-2945b-3p", "aal-miR-2945-3p", "aal-miR-2a-3p", "aal-miR-33b-5p", "aal-miR-4110-5p", "aal-miR-5706", "aal-miR-622", "aal-miR-87", "aal-miR-970-3p", "aal-miR-993-3p")

# Filter the dataset for all microRNAs in one step
filtered_data_miranda <- aal_miranda_tx_names %>%
  filter(microRNA %in% microRNA_list_miranda)

# Split the filtered data into a list of data frames, one for each microRNA
mirna_list_miranda <- split(filtered_data_miranda, filtered_data_miranda$microRNA)

# Apply additional filtering (e.g., highest score and lowest energy)
candidates_miranda <<- lapply(mirna_list_miranda, function(df) {
  df %>%
    arrange(desc(score), energy) %>% # Sort by highest score and lowest energy
    filter(energy <= -14) %>% # Filter by energy <= -14 kcal/mol
    # old iteration had removed unspecified products
    filter(!duplicated(uniprot_id)) # Remove duplicates based on uniprot_id
})

# Access each miRNA data frame by its name
View(candidates_miranda[["aal-miR-1767"]])
# View(candidates_miranda[["aae-miR-276-3p"]])

# Also filter and sort dataframe with all the up-regulated miRNAs
aal_miranda_tx_names_sorted <- aal_miranda_tx_names %>%
  arrange(desc(score), energy) %>% # Sort by highest score and lowest energy
  filter(energy <= -14) %>% # Filter by energy <= -14 kcal/mol
  # old iteration had removed unspecified products
  filter(!duplicated(uniprot_id)) # Remove duplicates based on uniprot_id

# ==== DOWNLOAD DATABASE ====
# save dataframe with all upregulated miRNAs
write.csv(aal_miranda_tx_names_sorted, file = "results/00-target-prediction/00-miRNAconsTarget/aal_up/miranda-aal/miranda-aal-uniprot-filtered.csv", row.names = FALSE)

# save filtered database
# Write each miRNA data frame to a separate CSV file
output_dir_mir <- "results/00-target-prediction/00-miRNAconsTarget/aal_up/miranda-aal/mirna-individuales" # Directory to save the CSV files

lapply(names(candidates_miranda), function(miRNA_name) {
  df <- candidates_miranda[[miRNA_name]]
  # Construct the file name
  file_name <- paste0(output_dir_mir, "/", gsub("-", "_", miRNA_name), ".csv")
  # Write the data frame to a CSV file
  write.csv(df, file = file_name, row.names = FALSE)
  # Optional: Print a message to confirm the file was written
  cat("Wrote CSV file for:", miRNA_name, "\n")
})
