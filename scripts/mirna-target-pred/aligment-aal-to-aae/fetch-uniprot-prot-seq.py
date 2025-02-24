# ~~~~~ FETCH UNIPROT PROTEIN SEQUENCES ~~~~~ #
# Import dependencies
from Bio import Entrez, SeqIO
import os
import pandas as pd

# Set your email address (required by NCBI)
Entrez.email = "livisu.pajares.r@upch.pe"

# Test data: Dictionary where keys are miRNA names and values are lists of UniProtKB accession numbers
miRNA_to_accessions = {
    'bantam_3p': ['A0A023ETG1',
                  'A0A182G3U1',
                  'A0A1W7R8D2',
                  'A0A1W7R8H3',
                  'A0A1W7R8K9'],
    'bantam_5p': ['A0A182G722',
                  'A0A182G9G0',
                  'A0A182H5K2',
                  'A0A182H9K9',
                  'A0A023EIG2'],
    'let_7': ['A0A182GB59',
              'A0A023ENA3',
              'A0A023ER27',
              'A0A023ESN0',
              'A0A023EVS8']
}

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

# Save a list of SeqRecord objects into a FASTA file.
def save_fasta_file(records, output_filename):
    with open(output_filename, "w") as output_handle:
        SeqIO.write(records, output_handle, "fasta")