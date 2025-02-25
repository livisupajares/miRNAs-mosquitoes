# ~~~~~ FETCH UNIPROT PROTEIN SEQUENCES ~~~~~ #
# Import dependencies
# WARNING! : Don't forget to install 'lxml' parser with mamba install lxml.
import os
import time

import requests
from bs4 import BeautifulSoup

# Test data for minimun working example: One file.
acc = "A0A023ETG1"  # Example from bantam-3p

# Add url to open a connection
url = f"https://rest.uniprot.org/uniprotkb/{acc}.fasta"
response = requests.get(url)

# Log if connection to UniprotKB sequence FASTA file exists
if response.status_code == 200:
    print(f"Success opening a connection to {acc}")
else:
    print(f"Error fetching {acc}: HTTP {response.status_code}")

# See main scrapped content in beautiful soup
fasta = response.text
soup = BeautifulSoup(fasta, "lxml")
print(f"Fetched FASTA for {acc}:\n", soup.prettify())

# Fetch main FASTA without html tags
