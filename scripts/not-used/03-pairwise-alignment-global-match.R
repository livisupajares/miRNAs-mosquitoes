# ~~~~ Pairwise alignment global of miRNAs ~~~~
# This script has the purpose to align the mature sequences of miRNAs infected with DENV-2 from Aedes aegypti and Aedes albopictus.

# ==== Load libraries ====
# Instala Biostrings si no lo tienes
if (!requireNamespace("BiocManager", quietly = TRUE)) {
  install.packages("BiocManager")
}
BiocManager::install("Biostrings")
BiocManager::install("pwalign")

# Carga la librería
library(Biostrings)
library(pwalign)

# ==== Load fasta files into RNAStringSet objects ====
# Lee archivos fasta que hacen match (common-mirna-names-aae-aal.R)
aegypti_match <- readRNAStringSet("sequences/aae_denv_match.fasta")
albopictus_match <- readRNAStringSet("sequences/aal_denv_match.fasta")

# ==== Strip species prefixes to find common names ====
names_aal_clean <- gsub("^aal-", "", names(albopictus_match))
names_aae_clean <- gsub("^aae-", "", names(aegypti_match))

# ==== Find shared miRNA names ====
common_names <- intersect(names_aal_clean, names_aae_clean)

# ==== Filter sequences by common names ====
# Map cleaned names back to full entries
albopictus_common <- albopictus_match[names_aal_clean %in% common_names]
aegypti_common <- aegypti_match[names_aae_clean %in% common_names]

# Ensure names are clean and aligned for pairing
names(albopictus_common) <- gsub("^aal-", "", names(albopictus_common))
names(aegypti_common) <- gsub("^aae-", "", names(aegypti_common))

# ==== Perform pairwise alignment only on matching names ====
alignment_list_match <- list()
score_vector <- numeric(length(common_names))
names(score_vector) <- common_names

for (mirna in common_names) {
  alignment <- pairwiseAlignment(
    pattern = albopictus_common[[mirna]],
    subject = aegypti_common[[mirna]],
    type = "global"
  )
  alignment_list_match[[mirna]] <- alignment
  score_vector[mirna] <- score(alignment)
}

# ==== Output results ====
cat("🧬 Alineamientos por nombre (1:1):\n\n")
for (mirna in common_names) {
  cat(paste0("▶ aal-", mirna, " vs aae-", mirna, "\n"))
  print(alignment_list_match[[mirna]])
  cat("\n")
}
