# ~~~~~ VENN DIAGRAM ~~~~~
# Significant enrichment with annotated targets
# 
# ===== IMPORT LIBRARIES ====
library(ggVennDiagram)
library(ggplot2)
library(paletteer)

# ===== IMPORT DATA ====
# aae-mir-2945-3p
## Mixed, incl. RNA binding protein fox-1 homolog 1-like, and H zone
set1 <- c("RBFOX2", "CELF3", "Q17FE8", "Q17FE9")
## RNA binding protein fox-1 homolog 1-like, and Regulation of striated 
## muscle cell differentiation
set2 <- c("RBFOX2", "CELF3", "Q17FE8", "Q17FE9")
## mRNA 3-UTR binding
set3 <- c("RBFOX2", "SECISBP2L", "LIN28A", "Q17FE8", "Q17FE9")

# Create a list
y <- list(set1, set2, set3)

# ==== CHART =====
# Look up color palettes
# Find it here: https://r-graph-gallery.com/color-palette-finder
paletteer_d("tvthemes::Alexandrite")

# Chart
p <- ggVennDiagram(y,
                   category.names = c("MIRBPF1H1LHZ",
                                      "RBPF1H1RSMCD",
                                      "mRNA 3-UTR binding"),
                   label = "count")

p + scale_fill_gradient(low="#751C6DFF",high = "#FDC067FF") +
  labs(title = "aae-miR-2945-3p annotated targets",
       subtitle = "Grouped by significant enrichment (FDR < 0.01)") +
  scale_x_continuous(expand = expansion(mult = .2))

# ==== CHART STATISTICS ====
# Construct venn class
venn_y = Venn(y)

# Find which targets are shared by the three sets
overlap(venn_y, 1:3)
# Find which targets are shared between sets 1 and 2, but not in the third
discern(venn_y, c("Set_1","Set_2"), 3)
# Find which targets are only in set 3 (not shared by other sets)
discern_overlap(venn_y, 3)

