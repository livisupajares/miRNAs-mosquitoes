# ~~~~~ FUSE ENRICHMENT RESULTS ~~~~~
# This script is used to fuse the enrichment results so at the end, we will get
# per-mirna stringdb, per-mirna shinygo, venny stringdb, venny shinygo, all stringdb, all shinygo, where each will have Aedes aegypti and Aedes albopictus.

# ==== IMPORT DATABASES TO BE FUSED ====
## Per miRNA
# Per-mirna shinygo
aae_per_mirna_shinygo <- read.csv("results/01-enrichment/prot-names-enriched/aae-per-mirna-shinygo-export.csv")
aal_per_mirna_shinygo <- read.csv("results/01-enrichment/prot-names-enriched/aal-per-mirna-shinygo-export.csv")
# Per mirna stringdb
aae_per_mirna_stringdb <- read.csv("results/01-enrichment/prot-names-enriched/aae-per-mirna-stringdb-export.csv")
aal_per_mirna_stringdb <- read.csv("results/01-enrichment/prot-names-enriched/aal-per-mirna-stringdb-export.csv")

## Venny
# Venny shinygo
aae_venny_shinygo <- read.csv("results/01-enrichment/prot-names-enriched/aae-venny-shinygo-export.csv")
aal_venny_shinygo <- read.csv("results/01-enrichment/prot-names-enriched/aal-venny-shinygo-export.csv")
# Venny stringdb
aae_venny_stringdb <- read.csv("results/01-enrichment/prot-names-enriched/aae-venny-stringdb-export.csv")
aal_venny_stringdb <- read.csv("results/01-enrichment/prot-names-enriched/aal-venny-stringdb-export.csv")

## All
# All shinygo
aae_all_shinygo <- read.csv("results/01-enrichment/prot-names-enriched/aae-all-shinygo-export.csv")
aal_all_shinygo <- read.csv("results/01-enrichment/prot-names-enriched/aal-all-shinygo-export.csv")
# All stringdb
aae_all_stringdb <- read.csv("results/01-enrichment/prot-names-enriched/aae-all-stringdb-export.csv")
aal_all_stringdb <- read.csv("results/01-enrichment/prot-names-enriched/aal-all-stringdb-export.csv")

# ==== FUSE DATA ====
# Fuse data frames by row binding
# Per miRNA
per_mirna_shinygo <- rbind(aae_per_mirna_shinygo, aal_per_mirna_shinygo)
per_mirna_stringdb <- rbind(aae_per_mirna_stringdb, aal_per_mirna_stringdb)

# Venny
venny_shinygo <- rbind(aae_venny_shinygo, aal_venny_shinygo)
venny_stringdb <- rbind(aae_venny_stringdb, aal_venny_stringdb)

# All
all_shinygo <- rbind(aae_all_shinygo, aal_all_shinygo)
all_stringdb <- rbind(aae_all_stringdb, aal_all_stringdb)
