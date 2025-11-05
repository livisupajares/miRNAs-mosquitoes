# ~~~~ MERGE ALL KEGG IDS ~~~~~
# After extracting the kegg ids from the blastKOALA
# we need to merge these new kegg ids to the original
# table and then see how many uniprot ids doesn't have 
# kegg ids

# ===== Libraries =====
library(dplyr)
library(tidylog, warn.conflicts = FALSE)

# ==== Import data =====
# Original tables
## Aedes aegypti
aae_original <- read.csv("results/03-ppi/aae_string_protein_annotations_with_kegg.tsv", sep = "\t", na.strings = c("", "NA"))

## Aedes albopcitus
aal_original <- read.csv("results/03-ppi/aal_string_protein_annotations_with_kegg.tsv", sep = "\t", na.strings = c("", "NA"))

# New tables with the new kegg ids
## Aedes aegypti
aae_blastkoala <- read.csv("results/03-ppi/blastkoala_keggid/aae_kegg_id.csv", na.strings = c("", "NA"))

## Aedes albopcitus
aal_blastkoala <- read.csv("results/03-ppi/blastkoala_keggid/aal_kegg_id.csv", na.strings = c("", "NA"))

# ==== Check duplicates ====
# Aedes aegypti
## Check for duplicated Uniprot IDs in aae_blastkoala
aae_any_duplicates <- aae_blastkoala %>%
  count(uniprot_id) %>%
  filter(n > 1)

if (nrow(aae_any_duplicates) > 0) {
  print("There are duplicated uniprot_id entries:")
  print(aae_any_duplicates)
} else {
  print("No duplicated uniprot_id found.")
}

# Aedes albopictus
## Check for duplicated Uniprot IDs in aal_blastkoala
aal_any_duplicates <- aal_blastkoala %>%
  count(uniprot_id) %>%
  filter(n > 1)

if (nrow(aal_any_duplicates) > 0) {
  print("There are duplicated uniprot_id entries:")
  print(aal_any_duplicates)
} else {
  print("No duplicated uniprot_id found.")
}

# ==== MERGE =====
# Create a new df and add kegg ids from aae_blastkoala to aae_original that have kegg_id as NA, match by uniprot ids

## Aedes aegypti
aae_all_keggids <- aae_original %>%
  left_join(aae_blastkoala, 
            by = c("mapped_id" = "uniprot_id")) %>%
  mutate(
    kegg_id = if_else(is.na(kegg_id.x) & !is.na(kegg_id.y), 
                      kegg_id.y, 
                      kegg_id.x)
  ) %>%
  select(-kegg_id.x, -kegg_id.y, -URL, -fasta_header, -identity)  # remove the temporary columns

## Aedes albopictus
aal_all_keggids <- aal_original %>%
  left_join(aal_blastkoala, 
            by = c("mapped_id" = "uniprot_id")) %>%
  mutate(
    kegg_id = if_else(is.na(kegg_id.x) & !is.na(kegg_id.y), 
                      kegg_id.y, 
                      kegg_id.x)
  ) %>%
  select(-kegg_id.x, -kegg_id.y, -URL, -fasta_header, -identity)  # remove the temporary columns

# ==== STATISTICS ====
# Count how many and which uniprot ids have no kegg_id
## Aedes aegypti original table
aae_original %>%
  summarise(
    total = n(),
    missing_kegg = sum(is.na(kegg_id)),
    with_kegg = sum(!is.na(kegg_id))
  )

## Aedes aegypti blastKOALA table
aae_blastkoala %>%
  summarise(
    total = n(),
    missing_kegg = sum(is.na(kegg_id)),
    with_kegg = sum(!is.na(kegg_id))
  )

## Aedes aegypti final table
# Count and extract mapped_id with NA in kegg_id
aae_na_kegg <- aae_all_keggids %>%
  filter(is.na(kegg_id)) %>%
  pull(mapped_id)  # extracts the vector of UniProt IDs

# Number of such entries
aae_n_na_kegg <- length(aae_na_kegg)

# Print results
cat("Number of proteins without KEGG ID:", aae_n_na_kegg, "\n")
print(aae_na_kegg)

# Count how many have kegg ids and how many don't have
aae_all_keggids %>%
  summarise(
    total = n(),
    missing_kegg = sum(is.na(kegg_id)),
    with_kegg = sum(!is.na(kegg_id))
  )

## Aedes albopictus original table
aal_original %>%
  summarise(
    total = n(),
    missing_kegg = sum(is.na(kegg_id)),
    with_kegg = sum(!is.na(kegg_id))
  )

## Aedes albopictus blastoKOALA table
aal_blastkoala %>%
  summarise(
    total = n(),
    missing_kegg = sum(is.na(kegg_id)),
    with_kegg = sum(!is.na(kegg_id))
  )

## Aedes albopictus final table
# Count and extract mapped_id with NA in kegg_id
aal_na_kegg <- aal_all_keggids %>%
  filter(is.na(kegg_id)) %>%
  pull(mapped_id)  # extracts the vector of UniProt IDs

# Number of such entries
aal_n_na_kegg <- length(aal_na_kegg)

# Print results
cat("Number of proteins without KEGG ID:", aal_n_na_kegg, "\n")
print(aal_na_kegg)

# Count how many have kegg ids and how many don't have
aal_all_keggids %>%
  summarise(
    total = n(),
    missing_kegg = sum(is.na(kegg_id)),
    with_kegg = sum(!is.na(kegg_id))
  )

# TODO: remove uniprot ids without kegg ids
# TODO: save final dataframe