# ~~~~~ FETCH UNIPROT PROTEIN SEQUENCES ~~~~~ #
# Import dependencies
import os
import time

import requests

# Test data: Dictionary where keys are miRNA names and values are lists of UniProtKB accession numbers
miRNA_to_accessions = {
    "bantam_3p": ["A0A023ETG1", "A0A182G3U1", "A0A1W7R8D2", "A0A1W7R8H3", "A0A1W7R8K9"],
    "bantam_5p": ["A0A182G722", "A0A182G9G0", "A0A182H5K2", "A0A182H9K9", "A0A023EIG2"],
    "let_7": ["A0A182GB59", "A0A023ENA3", "A0A023ER27", "A0A023ESN0", "A0A023EVS8"],
}

# Base URL for UniProt REST API
base_url = "https://rest.uniprot.org/uniprotkb/{acc}.fasta"

# Output directory to store the FASTA files
output_dir = "/Users/skinofmyeden/Documents/01-livs/14-programming/git/miRNAs-mosquitoes/sequences/test/miRNAtarget_prot_seq"

# Add a directory to deposit logs in case an accession can't be fetched
log_directory = f"{output_dir}/logs"

# Create the output directory if it doesn't exist
try:
    os.makedirs(output_dir, exist_ok=True)
    print(f"Output directory created or already exists: {output_dir}")
except Exception as output_dir:
    print(f"Error creating output directory: {output_dir}")
    exit(1)  # Exit the script if the directory cannot be created

# Create log directory if it doesn't exist
try:
    os.makedirs(log_directory, exist_ok=True)
    print(f"Output directory created or already exists: {log_directory}")
except Exception as log_directory:
    print(f"Error creating log directory: {log_directory}")
    exit(1)  # Exit the script if the directory cannot be created


# Function to fetch and save a UniProt sequence
def fetch_and_save_sequence(acc, mirna_name):
    url = base_url.format(acc=acc)  # Replace {acc} with the actual accession ID
    response = requests.get(url)

    if response.status_code == 200:
        # Extract plain text content
        print(f"Success fetching {acc}")
        return response.text  # Return the FASTA content
    else:
        # Log the error to the log file
        log_file = os.path.join(log_directory, f"log_{mirna_name}.log")
        error_message = f"Error fetching {acc}: HTTP {response.status_code}"
        print(error_message)
        with open(log_file, "a") as log:
            log.write(f"{error_message}\n")
        return None


# Iterate over the dictionary and process each miRNA and its accessions
for mirna, accessions in miRNA_to_accessions.items():
    print(f"Processing miRNA: {mirna}")

    # Collect all FASTA sequences for the current miRNA
    fasta_sequences = []
    for acc in accessions:
        fasta_content = fetch_and_save_sequence(acc, mirna)
        if fasta_content:
            fasta_sequences.append(fasta_content)
        time.sleep(1)

    # Save all sequences for the current miRNA into one FASTA file
    if fasta_sequences:
        fasta_filename = os.path.join(output_dir, f"{mirna}.fasta")
        with open(fasta_filename, "w") as fasta_file:
            fasta_file.write(
                "\n".join(fasta_sequences)
            )  # Combine all sequences into one file
        print(f"Saved all sequences for {mirna} to {fasta_filename}")
    else:
        print(f"No sequences fetched for {mirna}")
