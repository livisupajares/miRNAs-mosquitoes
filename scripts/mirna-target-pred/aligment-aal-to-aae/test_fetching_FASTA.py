# ~~~~~ FETCH UNIPROT PROTEIN SEQUENCES ~~~~~ #
# Import dependencies
import os
import time

import requests

# Test data for minimun working example: One file.
acc = "A0A023ETG1"  # Example from bantam-3p

# Add url to open a connection
url = f"https://rest.uniprot.org/uniprotkb/{acc}.fasta"
response = requests.get(url)

# Log if connection to UniprotKB sequence FASTA file exists
if response.status_code == 200:
    print(f"Success opening a connection to {acc}")
    # Extract plain text content
    fasta_content = response.text

    # Split content into header and sequence
    lines = fasta_content.splitlines()
    header = lines[0]  # First line is header
    sequence = "".join(lines[1:])  # Remaining lines are the sequence
else:
    print(f"Error fetching {acc}: HTTP {response.status_code}")
