# ~~~~~ VENN DIAGRAM ~~~~~
# Significant enrichment with annotated targets
# 
# ===== IMPORT LIBRARIES ====
library(venny)
library(RColorBrewer)

# ===== IMPORT DATA ====
# aae-mir-2945-3p
set1 <- c("RBFOX2", "CELF3", "Q17FE8", "Q17FE9")
set2 <- c("RBFOX2", "CELF3", "Q17FE8", "Q17FE9")
set3 <- c("RBFOX2", "SECISBP2L", "LIN28A", "Q17FE8", "Q17FE9")

# Generate color palette
myCol <- brewer.pal(3, "Pastel2")

# ==== CHART =====
# Chart
