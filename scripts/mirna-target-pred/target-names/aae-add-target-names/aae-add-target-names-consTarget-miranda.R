# ~~~~~ ADD TARGET NAMES ~~~~~ #
# ===== Load libraries & files =====
library("dplyr")
source("scripts/functions.R")

# ===== Importing data ===== #
# Add NA to all empty spaces
# Miranda
aae_miranda <- read.delim("results/miRNAconsTarget/miRNAconsTarget_aae_all/miranda-aae/miranda-aae.csv")

# vectorbase aal transcripts Foshan strain
aal_vectorbase <- read.csv("databases/vector-base-mosquitos/aal-transcript-names-vectorbase.csv")

# ==== FIX DATA ==== #
# Eliminate all decimal parts without rounding
aae_miranda$mRNA <- sub("\\..*", "", aae_miranda$mRNA)

# Change variable name to match the other databases
colnames(aal_vectorbase) <- c("gene_id", "transcript_id", "organism", "gene_name", "transcript_product_descrip", "uniprot_id")

# Filter the columns we will add to the aae_miranda dataframes
aal_important_transcr <- aal_vectorbase %>% select("transcript_id", "transcript_product_descrip", "uniprot_id")

# ==== MERGE DATABASES ====
# merge aae_miranda with aal_vectorbase matching transcript_ID
aae_miranda_tx_names <- merge(aae_miranda, aal_important_transcr, by.x = "mRNA", by.y = "transcript_id", all.x = TRUE)

# reorder columns so transcript product description and uniprot_id are
# between mRNA and miRNA columns.
aae_miranda_tx_names <- reorder_columns(aae_miranda_tx_names)

# ==== FINDING THE BEST mRNA TARGET CANDIDATES ====
# https://genomebiology.biomedcentral.com/articles/10.1186/gb-2003-5-1-r1
# https://bmcbioinformatics.biomedcentral.com/articles/10.1186/1471-2105-11-292

# List of microRNAs to filter by
microRNA_list_miranda <- c(
  "aae-miR-210-5p", "aae-miR-276-3p", "aae-miR-276-5p", "aae-miR-2945-3p",
  "aae-miR-305-5p", "aae-miR-34-5p", "aae-miR-1000-5p", "aae-miR-308-3p",
  "aae-miR-999-3p", "aae-bantam-3p", "aae-bantam-5p", "aae-let-7",
  "aae-miR-10-5p", "aae-miR-1175-3p", "aae-miR-11900", "aae-miR-124-3p",
  "aae-miR-3368-5p", "aae-miR-3722-5p", "aae-miR-4275-5p", "aae-miR-5108-5p",
  "aae-miR-5119-5p", "aae-miR-932-5p"
)

# Filter the dataset for all microRNAs in one step
filtered_data_miranda <- aae_miranda_tx_names %>%
  filter(microRNA %in% microRNA_list_miranda)

# Split the filtered data into a list of data frames, one for each microRNA
mirna_list_miranda <- split(filtered_data_miranda, filtered_data_miranda$microRNA)

# Apply additional filtering (e.g., highest score and lowest energy)
candidates_miranda <- lapply(mirna_list_miranda, function(df) {
  df %>%
    arrange(desc(score), energy) %>% # Sort by highest score and lowest energy
    filter(energy <= -14 & transcript_product_descrip != "unspecified product") %>% # Filter by energy <= -14 kcal/mol and remove unspecified products
    filter(!duplicated(uniprot_id)) # Remove duplicates based on uniprot_id
})

# Assign each miRNA's data frame to a separate variable in the global environment
# names(candidates_miranda) <- names(mirna_list_miranda)
# list2env(candidates_miranda, envir = .GlobalEnv)

# Access each miRNA data frame by its name
View(candidates_miranda[["aae-miR-210-5p"]])
# View(candidates_miranda[["aae-miR-276-3p"]])

# ==== DOWNLOAD DATABASE ====
# save filtered database
# Write each miRNA data frame to a separate CSV file
output_dir_mir <- "results/miRNAconsTarget/miRNAconsTarget_aae_all/miranda-aae/mirna-individuales-aae-miranda" # Directory to save the CSV files

lapply(names(candidates_miranda), function(miRNA_name) {
  df <- candidates_miranda[[miRNA_name]]
  # Construct the file name
  file_name <- paste0(output_dir_mir, "/", gsub("-", "_", miRNA_name), ".csv")
  # Write the data frame to a CSV file
  write.csv(df, file = file_name, row.names = FALSE)
  # Optional: Print a message to confirm the file was written
  cat("Wrote CSV file for:", miRNA_name, "\n")
})
