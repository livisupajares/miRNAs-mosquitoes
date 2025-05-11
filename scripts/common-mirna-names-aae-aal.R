# ~~~~~~miRNA name comparison ~~~~~~
# This script was made to compare up-regulated miRNA names from Aedes albopictus with up or down-regulated miRNA names from Aedes aegypti.
# Later on, we also kept the mature sequences on each miRNA for posterior pairwise alignment.

# ==== Importing Data ====
# Importing csv with Aedes aegypti names and sequences
aae_mirna_names <- read.csv("results/aae_mat_denv.csv",
  na.strings = c("", "NA")
)

# Importing csv with Aedes albopictus names and sequences
aal_mirna_names <- read.csv("results/aal_mat_denv_final.csv",
  na.strings = c("", "NA")
)

# ==== Remove the mat_seq column ====
# Remove the mat_seq column from Aedes aegypti dataframe
# aae_mirna_names <- aae_mirna_names[-c(2)]

# Remove the mat_seq column from Aedes albopictus dataframe
# aal_mirna_names <- aal_mirna_names[-c(2)]

# Add the 'i' into a cell because I misspelled 'miR' in Aedes albopictus
aal_mirna_names[4, 1] <- "aal-miR-1767"

# ==== Removing the species identifier (aae- or aal-) ====
# Removing the species identifier from Aedes aegypti from all strings in mirna_name column
aae_mirna_names$mirna_name <- gsub("aae-", "", aae_mirna_names$mirna_name)

# Removing the species identifier from Aedes albopictus from all strings in mirna_name column
aal_mirna_names$mirna_name <- gsub("aal-", "", aal_mirna_names$mirna_name)

# ==== Comparing all strings from mirna_name column of aae_mirna_names and aal_mirna_names ====
# Looking for values in any row, not necessary the same
matches <- aae_mirna_names$mirna_name %in% aal_mirna_names$mirna_name
which(matches)

# miRNA names from Aedes aegypti (up or down-regulated) that are also found in Aedes albopictus up-regulated miRNAs
matching_mirnas <- aae_mirna_names$mirna_name[matches]

# Find the indexes of the matching miRNAs in the Aedes albopictus dataframe
matching_rows_in_aal <- which(aal_mirna_names$mirna_name %in% matching_mirnas)

# See a vector with the miRNA names from Aedes aegypti and Aedes albopictus that match
aal_mirna_names[matching_rows_in_aal, ]
