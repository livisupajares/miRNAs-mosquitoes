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

# Lee los archivos fasta
albopictus <- readRNAStringSet("sequences/aal-complete/aal_mat_denv.fasta")
aegypti <- readRNAStringSet("sequences/aae-complete/aae_mat_denv.fasta")

# Obtener nombres e IDs
names_albo <- names(albopictus)
names_aegypti <- names(aegypti)

# Crear listas para guardar alineamientos y scores
alignment_list <- list() # The alignments estarán en esta lista
score_matrix <- matrix(NA, nrow = length(albopictus), ncol = length(aegypti),
                       dimnames = list(names_albo, names_aegypti))

# Alinear cada combinación y guardar score y alineamiento
for (i in seq_along(albopictus)) {
  for (j in seq_along(aegypti)) {
    alignment <- pairwiseAlignment(pattern = albopictus[[i]],
                                   subject = aegypti[[j]],
                                   type = "global")
    score_matrix[i, j] <- score(alignment)
    alignment_list[[paste(names_albo[i], names_aegypti[j], sep = "_vs_")]] <- alignment
  }
}

# Encontrar los mejores matches y mostrar secuencias alineadas
# Alignments with better scores but with gaps in the middle aren't considered
cat("🧬 Mejores alineamientos:\n\n")
for (i in seq_along(albopictus)) {
  # Buscar el mejor match
  best_j <- which.max(score_matrix[i, ])
  best_name <- names_aegypti[best_j]
  key <- paste(names_albo[i], best_name, sep = "_vs_")
  best_alignment <- alignment_list[[key]]

  # Imprimir resultados
  cat(paste0("▶ ", names_albo[i], " vs ", best_name, "\n"))
  print(best_alignment)
  cat("\n")
}
