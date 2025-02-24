# ~~~~~ FETCH UNIPROT PROTEIN SEQUENCES ~~~~~ #
# Import dependencies
from Bio import Entrez, SeqIO
import os
import pandas as pd
import requests

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

# Fetch a protein sequence from UniProt given an accession number.
def fetch_uniprot_sequence(acc):
    url = f"https://rest.uniprot.org/uniprotkb/{acc}.fasta"
    response = requests.get(url)
    
    if response.status_code == 200:
        return response.text  # Returns the FASTA-formatted sequence
    else:
        print(f"Error fetching {acc}: HTTP {response.status_code}")
        return None

# Fetch protein sequences from UniProtKB given a list of accession numbers.
def fetch_protein_sequences(accession_numbers):
    protein_records = []
    
    for acc in accession_numbers:
        fasta_sequence = fetch_uniprot_sequence(acc)
        if fasta_sequence:
            protein_records.append(fasta_sequence)
    
    return protein_records

# Main function
def main():
    # Create a directory to store the FASTA files if it doesn't exist
    output_dir = "/home/cayetano/livisu/git/miRNAs-mosquitoes/sequences/test/miRNAtarget_prot_seq"
    os.makedirs(output_dir, exist_ok=True)

    # Iterate over each miRNA and its associated accession numbers
    for mirna, accessions in miRNA_to_accessions.items():
        print(f"Processing {mirna}...")
        
        # Fetch protein sequences for the current miRNA's accession numbers
        protein_records = fetch_protein_sequences(accessions)
        
        # Define the output FASTA filename for the current miRNA
        fasta_filename = os.path.join(output_dir, f"{mirna}.fasta")
        
        print(f"Saved {len(protein_records)} sequences to {fasta_filename}")

#  Allow the script to be executed as a standalone program
if __name__ == "__main__":
    main()