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

# Import libraries
import requests
from bs4 import BeautifulSoup
import re
import pandas as pd

# Agrrgar url
# Se puede cambiar la dirección del website con los resultados específicos
# del blastKOALA
website = 'https://www.kegg.jp/tool-bin/blastkoala_result_list?id=15f4d11b20b6a6a8c0bf9ca63a1c645f1cfa223e&passwd=9zX64O&type=blastkoala'

# We can extract the "soup" of HTML from the main website
main_list = requests.get(website)
soup = BeautifulSoup(main_list.text, 'html.parser')

# Create a table with all uniprot IDs and their links
data = []
# Find all anchor tags with the target="_gene" attribute
gene_links = soup.find_all('a', target='_gene')

for link in gene_links:
    url = link['href']
    fasta_header = link.text.split(' ')[0] # Extract the text before the space
    # Use regex to extract the Uniprot ID from the fasta header
    match = re.search(r'tr\|(.+?)\|', fasta_header)
    uniprot_id = match.group(1) if match else None
    
    # If regex match fails, check if it's a Uniparc ID and use fasta_header
    if uniprot_id is None and fasta_header.startswith('UPI'):
        uniprot_id = fasta_header

    data.append({'URL': url, 'fasta_header': fasta_header, 'uniprot_id': uniprot_id})

df = pd.DataFrame(data)
print(df.head())

# Now we enter each url and for each url we extract the desired kegg_id
# and Identity

results = []
# Remove this line
for index, row in df.iterrows():
    gene_list_url = row['URL']
    response = requests.get(gene_list_url)
    soup_gene_list = BeautifulSoup(response.text, 'html.parser')
    gene_entries = []
    # Find the table within the frame1 div
    table = soup_gene_list.find('div', class_='frame1').find('table')
    # Iterate through table rows, skipping the header
    for tr in table.find_all('tr')[1:]:
        tds = tr.find_all('td')
        if len(tds) > 4: # Ensure there are enough columns
            # Extract KEGG ID from the anchor tag in the 1st td (index 0) with target="_kid"
            kegg_link = tds[0].find('a', target='_kid')
            kegg_id = kegg_link.text if kegg_link else None
            # Extract Identity score from the 3rd td (index 2)
            identity_score = tds[2].text.strip()
            try:
                identity_score = float(identity_score)
            except ValueError:
                identity_score = None # Handle cases where conversion fails

            gene_entries.append({'kegg_id': kegg_id, 'identity': identity_score})
    # This list 'gene_entries' now contains all entries for the current row's URL
    # The next steps will process this list to find the best match and append to df
    # For now, we just continue the loop to process the next row
    filtered_entries = [entry for entry in gene_entries if entry['identity'] is not None and entry['identity'] >= 80]

    selected_kegg_id = None
    selected_identity = None

    if filtered_entries:
        best_match = max(filtered_entries, key=lambda x: x['identity'])
        selected_kegg_id = best_match['kegg_id']
        selected_identity = best_match['identity']

    results.append({'uniprot_id': row['uniprot_id'], 'kegg_id': selected_kegg_id, 'identity': selected_identity})

final_df = pd.DataFrame(results)
# Drop existing 'kegg_id' and 'identity' columns if they exist before merging
df = df.drop(columns=['kegg_id', 'identity'], errors='ignore')
df = pd.merge(df, final_df, on='uniprot_id', how='left')
print(df.head())

# Save the final DataFrame to a CSV file
# Always change the name of the file to avoid overwritting
df.to_csv('/home/cayetano/livisu/git/miRNAs-mosquitoes/results/03-ppi/blastkoala_keggid/aal_kegg_id.csv', index=False)