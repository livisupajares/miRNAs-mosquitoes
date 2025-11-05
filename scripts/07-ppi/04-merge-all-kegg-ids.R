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

