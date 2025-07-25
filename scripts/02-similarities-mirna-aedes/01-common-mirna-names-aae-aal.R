# ~~~~~~miRNA match by name Aedes ~~~~~~
# This script was made to compare up-regulated miRNA names from Aedes albopictus with up or down-regulated miRNA names from Aedes aegypti.
# Later on, we also kept the mature sequences on each miRNA for posterior pairwise alignment.

# ==== Source custom fuctions ====
source("scripts/functions.R")

# ==== Importing Data ====
# Importing csv with up and down- regulated Aedes aegypti names and sequences
aae_mirna_names <- read.csv("results/00-isolating-mature-sequences/aae_mat_denv_up_down_seq.csv",
  na.strings = c("", "NA")
)

# Importing csv with up-regulated Aedes albopictus names and sequences
aal_mirna_names <- read.csv("results/00-isolating-mature-sequences/aal_mat_denv_up_seq.csv",
  na.strings = c("", "NA")
)

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

# ==== Update dataframes with the miRNA names that match ====
# Update Aedes aegypti dataframe with the miRNA names that match
aal_mirna_names <- aal_mirna_names[matching_rows_in_aal, ]

# Update Aedes aegypti dataframe with the miRNA names that match
aae_mirna_names <- aae_mirna_names[aae_mirna_names$mirna_name %in% aal_mirna_names$mirna_name, ]

# ==== Convert the dataframes into fasta and save them ====
# Convert the Aedes aegypti dataframe into fasta format
df_2_fasta(aae_mirna_names, "sequences/02-similarities-mirna-aedes/aae_denv_match.fasta")

# Convert the Aedes albopictus dataframe into fasta format
df_2_fasta(aal_mirna_names, "sequences/02-similarities-mirna-aedes/aal_denv_match.fasta")
