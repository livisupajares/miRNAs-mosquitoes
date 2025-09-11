# ~~~~~ REFORMAT FASTA ~~~~~~ #
# This script is done to reformat multiple FASTA headers, according to ortho-
# finder Example_files to try to avoid the following Orthofinder errors:
# "A duplicate accession was found using just first part:
# sp|A0A1S4FGH1|FXDIR_AEDAE"
# "Tried to use only the first part of the accession in order to list the
# sequences in each orthogroup more concisely but these were not unique. The
# full accession line will be used instead."
# "Warning: Leaf name 'uniprot-aae-miranda-all_UPI000B791CB6 status_active' not
# found in mapping dictionary for OG0000028"
"""
Clean FASTA headers for OrthoFinder / Cytoscape
- Keeps ALL entries (including UPI)
- Converts headers to: >SpeciesCode|GeneID
- Generates mapping table
"""

