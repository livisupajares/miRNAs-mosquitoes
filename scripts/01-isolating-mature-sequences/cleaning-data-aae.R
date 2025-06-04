# ~~~~~ ISOLATING AEDES AEGYPTI MIRNA SEQUENCES ~~~~~~
# TODO: rewrite this code to use dplyr

# ===== Load libraries & files =====
library("dplyr")
source("scripts/functions.R")

# ===== Importing data =====
# Add NA to all empty spaces
aae_mirna <- read.csv("databases/01-isolating-mature-sequences/aae-mirna.csv",
  na.strings = c("", "NA")
)

# Add aae- before miRNA name
aae_mirna$mirna_name <- paste0("aae-", aae_mirna$mirna_name)
# Total number of unique miRNAs
length(unique(aae_mirna$mirna_name)) # 123

# ===== Deleting extra columns =====
# Show name of columns
colnames(aae_mirna)

# Isolating miRNA sequences
## Mature sequence of aae infected with DENV-2
aae_mirna_subset <- aae_mirna[-c(1, 3, 5:20, 23:43, 45)]

# ==== Deleting all data with NA strings ====
# Delete NA rows with NA values only from the column mat_seq
aae_mirna_clean <- subset(aae_mirna_subset, !(is.na(mat_seq)))

# Total number of unique miRNAs
length(unique(aae_mirna_clean$mirna_name)) # 117

# ==== Subsetting miRNAs in DENV ====
aae_mirna_mat_denv <-
  aae_mirna_clean[grepl("denv", aae_mirna_clean$infection), ]

# Total number of unique miRNAs
length(unique(aae_mirna_mat_denv$mirna_name)) # 22

# ==== Deleting duplicated rows based on miRNA_name ====
aae_mirna_mat_denv <-
  aae_mirna_mat_denv[!duplicated(aae_mirna_mat_denv$mirna_name), ]
# Total number of unique miRNAs
length(unique(aae_mirna_mat_denv$mirna_name)) # 22

# ==== Filtering two dataframes with up and down regulated miRNAs ====
aae_mirna_mat_denv_up <-
  aae_mirna_mat_denv[grepl("up-regulated", aae_mirna_mat_denv$exp_DENV), ]
# Total number of unique miRNAs
length(unique(aae_mirna_mat_denv_up$mirna_name)) # 2

aae_mirna_mat_denv_down <-
  aae_mirna_mat_denv[grepl("down-regulated", aae_mirna_mat_denv$exp_DENV), ]
# Total number of unique miRNAs
length(unique(aae_mirna_mat_denv_down$mirna_name)) # 20

# Deleting the infection and exp_DENV column
aae_mirna_mat_denv <- aae_mirna_mat_denv[-c(3:5)]
aae_mirna_mat_denv_up <- aae_mirna_mat_denv_up[-c(3:5)]
aae_mirna_mat_denv_down <- aae_mirna_mat_denv_down[-c(3:5)]

# ==== Delete the numbers from miRNA strings ====
# Delete numbers
aae_mirna_mat_denv$mat_seq <- gsub("[0-9]", "", aae_mirna_mat_denv$mat_seq)
aae_mirna_mat_denv_up$mat_seq <- gsub("[0-9]", "", aae_mirna_mat_denv_up$mat_seq)
aae_mirna_mat_denv_down$mat_seq <- gsub("[0-9]", "", aae_mirna_mat_denv_down$mat_seq)

# Delete hyphens
aae_mirna_mat_denv$mat_seq <- gsub("-", "", aae_mirna_mat_denv$mat_seq)
aae_mirna_mat_denv_up$mat_seq <- gsub("-", "", aae_mirna_mat_denv_up$mat_seq)
aae_mirna_mat_denv_down$mat_seq <- gsub("-", "", aae_mirna_mat_denv_down$mat_seq)

# Delete blank spaces
aae_mirna_mat_denv$mat_seq <- gsub(" ", "", aae_mirna_mat_denv$mat_seq)
aae_mirna_mat_denv_up$mat_seq <- gsub(" ", "", aae_mirna_mat_denv_up$mat_seq)
aae_mirna_mat_denv_down$mat_seq <- gsub(" ", "", aae_mirna_mat_denv_down$mat_seq)

# ===== Save the final data frame =====
# Up and down-regulated together
write.csv(
  aae_mirna_mat_denv,
  "databases/01-isolating-mature-sequences/aae_mat_denv_up_down_seq.csv",
  row.names = FALSE
)

# Up-regulated
write.csv(
  aae_mirna_mat_denv_up,
  "databases/01-isolating-mature-sequences/aae_mat_denv_up_seq.csv",
  row.names = FALSE
)

# down-regulated
write.csv(
  aae_mirna_mat_denv_down,
  "databases/01-isolating-mature-sequences/aae_mat_denv_down_seq.csv",
  row.names = FALSE
)

# ==== Convert df to fasta ====
# up and down-regulated together
df_2_fasta(aae_mirna_mat_denv, "sequences/01-isolating-mature-sequences/aae_mat_denv_up_down.fasta")

# up-regulated
df_2_fasta(aae_mirna_mat_denv_up, "sequences/01-isolating-mature-sequences/aae_mat_denv_up.fasta")

# down-regulated
df_2_fasta(aae_mirna_mat_denv_down, "sequences/01-isolating-mature-sequences/aae_mat_denv_down.fasta")
