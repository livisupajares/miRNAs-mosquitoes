# ~~~~~ TEST = ISOLATE AEDES ALBOPICTUS MIRNA SEQUENCES ~~~~~~
#
# ===== Load libraries & files =====
library(dplyr)
source("scripts/functions.R")

# ===== Importing data =====
# Add NA to all empty spaces
aal_mirna <- read.csv("sequences/aal-complete/aal-mirna-seq.csv",
  na.strings = c("", "NA")
)

# Add aal- before miRNA name
aal_mirna$mirna_name <- paste0("aal-", aal_mirna$mirna_name)

# ===== Deleting extra columns =====
# Show name of columns
colnames(aal_mirna)
aal_mirna_mat_subset <- aal_mirna[-c(2, 4:20, 23:38)]

# ==== Deleting data that aren't nucleotides ====
# Equivalente a eliminar los NAs
aal_mirna_mat_subset <- aal_mirna_mat_subset[!grepl(
  "NO HAY SECUENCIA",
  aal_mirna_mat_subset$mat_seq
), ]

# Count unique miRNA names
n_unique <- length(unique(aal_mirna_mat_subset$mirna_name))
print(n_unique) # 113

# ==== Deleting data that is not from DENV-2 ====
# Filter by denv infection
aal_mirna_mat_denv <- aal_mirna_mat_subset[grepl(
  "denv",
  aal_mirna_mat_subset$infection
), ]

# Count unique miRNA names infected with miRNA
n_unique_denv <- length(unique(aal_mirna_mat_denv$mirna_name))
print(n_unique_denv) # 62

# ==== Fix NA values that I forgot to add ====
# Reset row names so R doesn't get confused with skipped rows from filtering
rownames(aal_mirna_mat_denv) <- NULL

# Get a matrix of [row, col] positions where NA occurs
na_positions <- which(is.na(aal_mirna_mat_denv), arr.ind = TRUE)

# Print result
print(na_positions)

# Convert column indices to column names
na_positions_df <- as.data.frame(which(is.na(aal_mirna_mat_denv), arr.ind = TRUE))

na_positions_df$varName <- names(aal_mirna_mat_denv)[na_positions_df$col]

# View the result
print(na_positions_df)

# View row number
which(is.na(aal_mirna_mat_denv$exp_DENV))

# Replace NA with "up-regulated", because I forgot to add said value in the .csv
aal_mirna_mat_denv[80, 4] <- "up-regulated"

# ==== Deleting duplicated rows based on miRNA_name ====
# # Some duplicates have both up-regulated and down-regulated in the same miRNA.

# Identify miRNAs with both up and down regulation
# There is 11 problematic miRNAs
problematic_mirnas <- aal_mirna_mat_denv %>%
  group_by(mirna_name) %>%
  filter("up-regulated" %in% exp_DENV & "down-regulated" %in% exp_DENV) %>% pull(mirna_name) %>%
  unique()

print(problematic_mirnas)

# Remove rows where mirna_name is in problematic_mirnas
aal_mirna_mat_denv_up_regulated <- 


# Deleting the infection column
aal_mirna_mat_denv_final <- aal_mirna_mat_denv_up[-c(3, 4)]

# ==== Delete the numbers from miRNA strings ====
# Delete parenthesis
aal_mirna_mat_denv_final$mat_seq <- gsub("\\(G\\)", "", aal_mirna_mat_denv_final$mat_seq)

# ==== Replace all Ts into Us ====
aal_mirna_mat_denv_final$mat_seq <- gsub("T", "U", aal_mirna_mat_denv_final$mat_seq)

# ===== Save the final data frame =====
write.csv(
  aal_mirna_mat_denv_final,
  "results/aal_mat_denv_final.csv",
  row.names = FALSE
)

# ==== Convert df to fasta ====
# convert df to fasta and save output into a custom location for
# subsequent analysis
df_2_fasta(aal_mirna_mat_denv_final, "sequences/aal-complete/aal_mat_denv.fasta")
