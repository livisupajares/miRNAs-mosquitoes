# ~~~~ Pairwise alignment global of miRNAs ~~~~ 
# Instala Biostrings si no lo tienes
if (!requireNamespace("BiocManager", quietly = TRUE))
  install.packages("BiocManager")
BiocManager::install("Biostrings")

# Carga la librería
library(Biostrings)

