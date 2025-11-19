# ~~~~ ORTHOSCAPE IMPORT ~~~~~
# This script prepares string ppi analysis export data and formats it for cytoscape's plugin orthoscape analysis as it requires kegg ids for all nodes.
# This script will take aedes_aegypti_STRING.tsv and aedes_albopictus_STRING.tsv and add the following columns:
# - After node2_string_id, add `node1_uniprot_id` and `node2_uniprot_id` with only uniprot ids (not the string taxon ID)
# - `id1` and `id2`: kegg ids of node 1 and 2
# `protein_name1` and `protein_name2`: eggnog mapper name.
#
# This script will take `aae_sring_node_degrees.tsv` and `aal_string_node_degrees.tsv` and add the following columns:
# - Between `Identifier` and `node_degree`, add `id` (kegg ids) and `protein_name` (eggnog mapper)
# Finally, it will remove nodes without kegg ids in both files for both species
#

# ==== IMPORT LIBRARIES ====
library(dplyr)
library(tidylog, warn.conflicts = FALSE)

# ==== IMPORT DATA ====
# Import node data
aae_edge <- read.csv("results/03-taxonomic-comparison/02-orthoscape-import/aae/aedes_aegypti_STRING.tsv", sep = "\t")
aal_edge <- read.csv("results/03-taxonomic-comparison/02-orthoscape-import/aal/aedes_albopictus_STRING.tsv", sep = "\t")

# Import node degree data
aae_degree <- read.csv("results/03-taxonomic-comparison/02-orthoscape-import/aae/aae_string_node_degrees.tsv", sep = "\t")
aal_degree <- read.csv("results/03-taxonomic-comparison/02-orthoscape-import/aal/aal_string_node_degrees.tsv", sep = "\t")

# Import data that have the kegg ids, uniprot ids and protein names (eggnog mapper)
## kegg ids + uniprot ids
aae_kegg_uniprot <- read.csv("results/03-taxonomic-comparison/01-add-kegg-ids/03-final_kegg_ids/aae_keggids.csv")
aal_kegg_uniprot <- read.csv("results/03-taxonomic-comparison/01-add-kegg-ids/03-final_kegg_ids/aal_keggids.csv")

## protein names
