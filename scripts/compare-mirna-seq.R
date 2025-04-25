# ~~~~ Compare FASTA sequences to see matches between them ~~~~~~ 
# Instala Biostrings si no lo tienes
if (!requireNamespace("BiocManager", quietly = TRUE))
  install.packages("BiocManager")
BiocManager::install("Biostrings")

# Carga la librería
library(Biostrings)

# Lee los archivos fasta
albopictus <- readRNAStringSet("sequences/aal-complete/aal_mat_denv.fasta")
aegypti <- readRNAStringSet("sequences/aae-complete/aae_mat_denv.fasta")

# Extrae las secuencias como vectores de caracteres
seqs_albo <- as.character(albopictus)
seqs_aegypti <- as.character(aegypti)

