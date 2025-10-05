# ~~~~~~ FETCH UNIPROT ACCESSION DATA ~~~~~~~~~~
# This script will get the full_expanded dataframes from 02-prots-enriched-process
# and for the `matching_proteins_id_network` variable (Uniprot IDs) will be used
# as input for UniProtKB GET API. Wrap the script in a logger and log failues.
# This script will get the following data and append results in the original
# `full_expanded` dataframes, where each data will be added in their own column:

# protein_name --> protein_name column
# gene_primary --> gene_primary column
# cc_function --> cc_function column
# go_p --> go_p column (GO Biological Process)
# go_f --> go_f column (GO Molecular Function)

# Detect if an entry has been moved to UniParc. If that's the case, then add 
# "NA" to all the other columns (protein_name, gene_primary, cc_function, go_p, 
# go_f). Then, log these IDs as failures in logs and print in console a summary 
# of the run.

# Run the script for each `full_expanded` dataframe.