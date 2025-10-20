# ~~~~~ MERGING ALL PER MIRNA ~~~~~
# This script is to see:
# - if some uniprot_id doesn't have any annotation or only one annotation
# - Add two variables `mirna_expression` and `common_mirna` to all per-mirna datasets
# - Merge all per-mirna datasets, including the ones with "down", including both species
# - Merge all "all" datasets, including both species.
# - Mantain sorting by `term_description` and by `false_discovery_rate`

