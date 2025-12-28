# ~~~~ CYTOSCAPE PPI IMPORT ~~~~~
# This script prepares string ppi analysis export data and formats it for cytoscape by adding the mapped protein names of the nodes for better visialization.
# This script will take interaction files from STRINGDB where the PPI analysis was significant and add the following columns:
# - After node2_string_id: it will add `node1_uniprot_id` and `node2_uniprot_id` with only uniprot ids (not the string taxon ID)
# `protein_name1` and `protein_name2`: eggnog mapper name.
#
# This script will take node degree files from STRINGDB where the PPI analysis was significant, and add the following columns:
# - Between `Identifier` and `node_degree`: it will add the `protein_name` (eggnog mapper)
# TODO: After seeing the results after importing into cytoscape, remove the nodes that map to the same protein name to reduce redundancy.

