# ~~~~~ FETCH UNIPROT PROTEIN SEQUENCES ~~~~~ #
# Import dependencies
import os

import requests

# Test data for minimun working example: One file.
acc = "A0A023ETG1"  # Example from bantam-3p

# Add url to open a connection
url = f"https://rest.uniprot.org/uniprotkb/{acc}.fasta"
response = requests.get(url)

# Log if connection to UniprotKB sequence FASTA file exists
if response.status_code == 200:
    print(f"Success fetching {acc}")
    # Extract plain text content
    fasta_content = response.text

    # Split content into header and sequence
    lines = fasta_content.splitlines()
    header = lines[0]  # First line is header
    sequence = "".join(lines[1:])  # Remaining lines are the sequence

    # Join header and sequence into one FASTA string
    bantam_3p = f"{header}\n{sequence}"
    print(bantam_3p)

    # Create a directory to store the FASTA files if it doesn't exist
    output_dir = "/Users/skinofmyeden/Documents/01-livs/14-programming/git/miRNAs-mosquitoes/sequences/test/miRNAtarget_prot_seq"
    try:
        os.makedirs(output_dir, exist_ok=True)
        print(f"Output directory created or already exists: {output_dir}")
    except Exception as output_dir:
        print(
            f"Error creating output directory: {output_dir}"
        )  # Exit the script if the directory cannot be created

    # Save 'bantam_3p' and write its contents into a file
    fasta_filename = os.path.join(
        output_dir, "bantam-3p.fasta"
    )  # Append mirna name and add .fasta extension to output for new name file
    with open(fasta_filename, "w") as fasta:
        fasta.write(bantam_3p)
        print(f"Saved {acc} to {fasta_filename}")
else:
    print(f"Error fetching {acc}: HTTP {response.status_code}")
