# ~~~~~ SCRAPPING blastKOALA ~~~~~~
# This is script was tested and made in google colab
# to scrap results from blastKOALA of uniprot ids without 
# kegg_ids provided by STRING DB or Uniprot mapper
# This script takes the table results from blastKOALA and 
# creates a brand new table with Uniprot ID, kegg_id and 
# Identity percentage.

# If there are many results for a single uniprot_id, it only
# filters the kegg_id with the highest identity percentage if
# it's higher than 80%