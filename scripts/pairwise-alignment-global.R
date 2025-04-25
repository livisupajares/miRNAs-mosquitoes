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

