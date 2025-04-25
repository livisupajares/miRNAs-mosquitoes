# ~~~~ Pairwise alignment global of miRNAs ~~~~ 
# Instala Biostrings si no lo tienes
if (!requireNamespace("BiocManager", quietly = TRUE))
  install.packages("BiocManager")
BiocManager::install("Biostrings")

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

