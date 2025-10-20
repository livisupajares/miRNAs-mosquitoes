# ~~~~~ INTERPROSCAN ANNOTATION STATISTICS ~~~~~
# This script is to see how many uniprot ids were not annotated with InterProScan
# and to add a column to isolate the uniprot_ids from the column that contains the fasta headers.

# ===== LOAD LIBRARIES =====
library(dplyr)
library(stringr)
library(tidylog, warn.conflicts = FALSE)

# ==== LOAD TSV DATA ======
aae_all_interpro <- read.csv("databases/05-interproscan/aae_all_annotated.tsv", sep = "\t", header = FALSE)
aae_all_down_interpro <- read.csv("databases/05-interproscan/aae_all_down_annotated.tsv", sep = "\t", header = FALSE)
aae_per_mirna_interpro <- read.csv("databases/05-interproscan/aae_per_mirna_annotated.tsv", sep = "\t", header = FALSE)
aae_per_minra_down_interpro <- read.csv("databases/05-interproscan/aae_per_mirna_down_annotated.tsv", sep = "\t", header = FALSE)
aal_all_interpro <- read.csv("databases/05-interproscan/aal_all_annotated.tsv", sep = "\t", header = FALSE)
aal_per_mirna_interpro <- read.csv("databases/05-interproscan/aal_per_mirna_annotated.tsv", sep = "\t", header = FALSE)

# ==== CREATE A LIST OF DATAFRAMES =====
interpro <- list(
  "aae_all_down" = aae_all_down_interpro,
  "aae_all" = aae_all_interpro,
  "aae_per_mirna" = aae_per_mirna_interpro,
  "aae_per_mirna_down" = aae_per_minra_down_interpro,
  "aal_all" = aal_all_interpro,
  "aal_per_mirna" = aal_per_mirna_interpro
)
# ==== ASIGN HEADERS =====
headers <- c("protein_accession", "md5", "seq_length", "analysis", "signature_accession", "signature_description", "start_location", "stop_location", "score", "status", "date", "interpro_accession", "interpro_description", "go_annotations", "pathways")

interpro_headers <- lapply(interpro, function(df) {
  colnames(df) <- headers
  return(df)
})

# ==== CLEAN DATA ====
interpro_clean <- lapply(interpro_headers, function(df) {
  # Add uniprot_id column with only uniprot ids
  df %>%
    mutate(
      uniprot_id = case_when(
        # If it matches UniProt format (starts with tr| or sp| etc.)
        str_detect(protein_accession, "^[a-z]{2}\\|[^|]+\\|") ~ str_extract(protein_accession, "^[a-z]{2}\\|([^|]+)\\|", group = 1),
        # Otherwise, assume it's UniParc or other ID → keep original
        TRUE ~ protein_accession
      ),
      .after = "protein_accession") %>%
    # Keep unique uniprot_id
    dplyr::distinct(uniprot_id, .keep_all = TRUE) %>%
    # Remove last two columns
    select(1:(ncol(.) - 2))
})
