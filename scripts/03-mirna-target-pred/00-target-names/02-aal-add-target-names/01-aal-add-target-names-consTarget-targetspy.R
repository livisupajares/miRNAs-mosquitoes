# ~~~~~ ADD TARGET NAMES ~~~~~ #
# ===== Load libraries & files =====
library("dplyr")
source("scripts/functions.R")

# ===== Importing data ===== #
# Add NA to all empty spaces
# Miranda
aal_targetspy <- read.csv("results/00-target-prediction/00-miRNAconsTarget/aal_up/targetspy-aal/targetspy-aal.csv")

# vectorbase aal transcripts Foshan strain
aal_vectorbase <- read.csv("databases/02-target-prediction/aal-transcript-names-vectorbase.csv")

# ==== FIX DATA ==== #
# Eliminate all decimal parts without rounding
aal_targetspy$mRNA <- sub("\\..*", "", aal_targetspy$mRNA)

# Change variable name to match the other databases
colnames(aal_vectorbase) <- c("gene_id", "transcript_id", "organism", "gene_name", "transcript_product_descrip", "uniprot_id")

# Filter the columns we will add to the aae_miranda dataframes
aal_important_transcr <- aal_vectorbase %>% select("transcript_id", "transcript_product_descrip", "uniprot_id")

# ==== MERGE DATABASES ====
# merge aae_miranda with aal_vectorbase matching transcript_ID
aal_targetspy_tx_names <- merge(aal_targetspy, aal_important_transcr, by.x = "mRNA", by.y = "transcript_id", all.x = TRUE)

# reorder columns so transcript product description and uniprot_id are
# between mRNA and miRNA columns.
aal_targetspy_tx_names <- reorder_columns(aal_targetspy_tx_names)

# ==== FINDING THE BEST mRNA TARGET CANDIDATES ====
# https://genomebiology.biomedcentral.com/articles/10.1186/gb-2003-5-1-r1
# https://bmcbioinformatics.biomedcentral.com/articles/10.1186/1471-2105-11-292

# List of microRNAs to filter by
microRNA_list_targetspy <- c("aal-miR-1767", "aal-miR-193-5p", "aal-miR-1951", "aal-miR-424-3p", "aal-miR-4728-5p", "aal-miR-976-5p", "aal-miR-998", "aal-miR-1889b-3p", "aal-miR-190-5p", "aal-miR-252b-5p", "aal-miR-276-5p", "aal-miR-2796-3p", "aal-miR-281-3p", "aal-miR-2943", "aal-miR-2945b-3p", "aal-miR-2945-3p", "aal-miR-2a-3p", "aal-miR-33b-5p", "aal-miR-4110-5p", "aal-miR-5706", "aal-miR-622", "aal-miR-87", "aal-miR-970-3p", "aal-miR-993-3p")

# Filter the dataset for all microRNAs in one step
filtered_data_targetspy <- aal_targetspy_tx_names %>%
  filter(microRNA %in% microRNA_list_targetspy)

# Split the filtered data into a list of data frames, one for each microRNA
mirna_list_targetspy <- split(filtered_data_targetspy, filtered_data_targetspy$microRNA)

# Apply additional filtering (e.g., highest score and lowest energy)
candidates_targetspy <- lapply(mirna_list_targetspy, function(df) {
  df %>%
    arrange(desc(score), energy) %>% # Sort by highest score and lowest energy
    filter(energy <= -14 & transcript_product_descrip != "unspecified product") %>% # Filter by energy <= -14 kcal/mol and remove unspecified products
    filter(!duplicated(uniprot_id)) # Remove duplicates based on uniprot_id
})

# Assign each miRNA's data frame to a separate variable in the global environment
# names(candidates_miranda) <- names(mirna_list_miranda)
# list2env(candidates_miranda, envir = .GlobalEnv)

# Access each miRNA data frame by its name
View(candidates_targetspy[["aal-miR-184"]])
# View(candidates_miranda[["aae-miR-276-3p"]])

# ==== DOWNLOAD DATABASE ====
# save dataframe with all upregulated miRNAs
write.csv(aal_targetspy_tx_names_sorted, file = "results/00-target-prediction/00-miRNAconsTarget/aal_up/targetspy-aal/targetspy-aal-uniprot-filtered.csv", row.names = FALSE)

# save filtered database
# Write each miRNA data frame to a separate CSV file
output_dir_mir <- "results/00-target-prediction/00-miRNAconsTarget/aal_up/targetspy-aal/mirna-individuales" # Directory to save the CSV files

lapply(names(candidates_targetspy), function(miRNA_name) {
  df <- candidates_miranda[[miRNA_name]]
  # Construct the file name
  file_name <- paste0(output_dir_mir, "/", gsub("-", "_", miRNA_name), ".csv")
  # Write the data frame to a CSV file
  write.csv(df, file = file_name, row.names = FALSE)
  # Optional: Print a message to confirm the file was written
  cat("Wrote CSV file for:", miRNA_name, "\n")
})
