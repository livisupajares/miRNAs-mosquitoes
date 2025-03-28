# ~~~~~ FETCH UNIPROT PROTEIN SEQUENCES ~~~~~ #
# miRNA can also be replaced for any .txt file inside a directory that contains
# uniprotkb and/or uniparc ids.
# Check the created logs to see if some accession file failed. If empty, then
# there hasn't been any errors fetching the accessions.

# Import dependencies
import os
import time

import requests
from tqdm import tqdm

# Configuration
# Input directory to read .txt files with Uniprot kb accessions
input_directory = (
    "/Users/skinofmyeden/Documents/01-livs/14-programming/git/miRNAs-mosquitoes/results"
)
# Output directory to store the FASTA files
output_dir = "/Users/skinofmyeden/Documents/01-livs/14-programming/git/miRNAs-mosquitoes/sequences/miRNAtarget_prot_seq"
# Add a directory to deposit logs in case an accession can't be fetched
log_directory = f"{output_dir}/logs"
# Base URL for UniProt REST API
base_url = "https://rest.uniprot.org/{database}/{acc}.fasta"

# Create directories if they don't exist
os.makedirs(output_dir, exist_ok=True)
os.makedirs(log_directory, exist_ok=True)


# Dynamically load miRNA names and accessions from files
def load_miRNA_accessions(input_dir):
    miRNA_to_accessions = {}
    for filename in os.listdir(input_dir):
        if filename.endswith(".txt"):
            mirna_name = os.path.splitext(filename)[0]  # Remove .txt extension
            file_path = os.path.join(input_dir, filename)
            with open(file_path, "r") as f:
                accessions = [line.strip() for line in f if line.strip()]
            miRNA_to_accessions[mirna_name] = accessions
    return miRNA_to_accessions


# Load the dictionary dynamically
miRNA_to_accessions = load_miRNA_accessions(input_directory)


# Function to fetch and save a UniProt sequence
def fetch_and_save_sequence(acc, mirna_name):
    # check the length of acc to choose an url
    if len(acc) >= 13:
        database = "uniparc"
    else:
        database = "uniprotkb"
    url = base_url.format(
        database=database, acc=acc
    )  # Replace {acc} with the actual accession ID
    response = requests.get(url)

    if response.status_code == 200:
        # Extract plain text content
        # print(f"Success fetching {acc} from {database}")
        return response.text
    else:
        # Log the error to the log file
        log_file = os.path.join(log_directory, f"log_{mirna_name}.log")
        error_message = (
            f"Error fetching {acc} from {database}: HTTP {response.status_code}"
        )
        # print(error_message)
        with open(log_file, "a") as log:
            log.write(f"{error_message}\n")
        return None


# Iterate over the dictionary and process each miRNA and its accessions
for mirna, accessions in miRNA_to_accessions.items():
    print(f"\nProcessing miRNA: {mirna} ({len(accessions)} accessions)")

    # Collect all FASTA sequences for the current miRNA
    fasta_sequences = []
    for acc in tqdm(accessions, desc=f"Fetching {mirna}", total=len(accessions)):
        fasta_content = fetch_and_save_sequence(acc, mirna)
        if fasta_content:
            fasta_sequences.append(fasta_content)
        time.sleep(0.0025)

    # Save all sequences for the current miRNA into one FASTA file
    if fasta_sequences:
        fasta_filename = os.path.join(output_dir, f"{mirna}.fasta")
        with open(fasta_filename, "w") as f:
            f.write("\n".join(fasta_sequences))  # Combine all sequences into one file
        print(f"Saved {len(fasta_sequences)} sequences for {mirna} to {fasta_filename}")
    else:
        print(f"No valid sequences found for {mirna}")
print("\nScript completed successfully.")
