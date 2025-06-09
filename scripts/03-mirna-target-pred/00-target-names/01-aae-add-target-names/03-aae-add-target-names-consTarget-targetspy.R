# ~~~~~ ADD TARGET NAMES ~~~~~ #
# ===== Load libraries & files =====
library("dplyr")
source("scripts/functions.R")

# ===== Importing data ===== #
# Add NA to all empty spaces
# ts
aae_ts <- read.csv("results/00-target-prediction/00-miRNAconsTarget/aae_up/targetspy-aae/targetspy-aae.csv")

# Add Aedes aegypti biomart metadata with uniprots for transcripts
aae_biomart <- read.csv("results/00-target-prediction/01-ensembl-metazoa-biomart/uniprots_aae_biomart.csv")

# ==== FIX DATA ==== #
# Eliminate all decimal parts without rounding
aae_ts$mRNA <- sub("\\..*", "", aae_ts$mRNA)

# Change variable name to match the other databases
colnames(aae_biomart) <- c("gene_id", "transcript_id", "uniprot_id")

# ==== MERGE DATABASES ====
# merge aae_ts with aal_vectorbase matching transcript_ID
aae_ts_tx_names <- merge(aae_ts, aae_biomart, by.x = "mRNA", by.y = "transcript_id", all.x = TRUE)

# reorder columns so transcript product description and uniprot_id are
# between mRNA and miRNA columns.
aae_ts_tx_names <- reorder_columns(aae_ts_tx_names)

# ==== FINDING THE BEST mRNA TARGET CANDIDATES ====
# https://genomebiology.biomedcentral.com/articles/10.1186/gb-2003-5-1-r1
# https://bmcbioinformatics.biomedcentral.com/articles/10.1186/1471-2105-11-292

# List of upregulated microRNAs to filter by
microRNA_list_ts <- c(
  "aae-miR-34-5p",
  "aae-miR-5119-5p"
)

# Filter the dataset for all microRNAs in one step
filtered_data_ts <- aae_ts_tx_names %>%
  filter(microRNA %in% microRNA_list_ts)

# Split the filtered data into a list of data frames, one for each microRNA
mirna_list_ts <- split(filtered_data_ts, filtered_data_ts$microRNA)

# Apply additional filtering (e.g., highest score and lowest energy)
candidates_ts <- lapply(mirna_list_ts, function(df) {
  df %>%
    arrange(desc(score), energy) %>% # Sort by highest score and lowest energy
    filter(energy <= -14) %>% # Filter by energy <= -14 kcal/mol
    filter(!duplicated(uniprot_id)) # Remove duplicates based on uniprot_id
})

# Access each miRNA data frame by its name
View(candidates_ts[["aae-miR-34-5p"]])
View(candidates_ts[["aae-miR-5119-5p"]])

# ==== DOWNLOAD DATABASE ====
# save filtered database
# Write each miRNA data frame to a separate CSV file
output_dir_mir <- "results/00-target-prediction/00-miRNAconsTarget/aae_up/targetspy-aae/mirna-individuales" # Directory to save the CSV files

lapply(names(candidates_ts), function(miRNA_name) {
  df <- candidates_ts[[miRNA_name]]
  # Construct the file name
  file_name <- paste0(output_dir_mir, "/", gsub("-", "_", miRNA_name), ".csv")
  # Write the data frame to a CSV file
  write.csv(df, file = file_name, row.names = FALSE)
  # Optional: Print a message to confirm the file was written
  cat("Wrote CSV file for:", miRNA_name, "\n")
})
