# ~~~~~ FETCH UNIPROT PROTEIN SEQUENCES ~~~~~ #
# Import dependencies
from Bio import Entrez, SeqIO
import os
import pandas as pd

# Set your email address (required by NCBI)
Entrez.email = "livisu.pajares.r@upch.pe"

# 

# Function to fetch protein sequences from UniProtKB given a list of accession numbers.
def fetch_protein_sequences(accession_numbers):
    protein_records = []
    
    for acc in accession_numbers:
        try:
            # Fetch the GenBank record from NCBI using the accession number
            handle = Entrez.efetch(db="protein", id=acc, rettype="gb", retmode="text")
            record = SeqIO.read(handle, "genbank")
            handle.close()
            
            # Append the record to the list of protein records
            protein_records.append(record)
        except Exception as e:
                print(f"Error fetching {acc}: {e}")
    
    return protein_records