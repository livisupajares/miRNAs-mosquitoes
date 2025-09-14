# ~~~~~ REFORMAT FASTA ~~~~~~ #
# This script is done to reformat multiple FASTA headers, according to ortho-
# finder Example_files to try to avoid the following Orthofinder errors:
# "A duplicate accession was found using just first part:
# sp|A0A1S4FGH1|FXDIR_AEDAE"
# "Tried to use only the first part of the accession in order to list the
# sequences in each orthogroup more concisely but these were not unique. The
# full accession line will be used instead."
# "Warning: Leaf name 'uniprot-aae-miranda-all_UPI000B791CB6 status_active' not
# found in mapping dictionary for OG0000028"
"""
Clean FASTA headers for OrthoFinder / Cytoscape
- Keeps ALL entries (including UPI)
- Converts headers to: >SpeciesCode|GeneID
- Generates mapping table
"""

import platform

# Import Packages
import re
import sys
from pathlib import Path


# Extract ID from header (Pick between VectorBase ID, UniProt or Uniparc)
def extract_id(header, species_code):
    """
    Extract the best possible ID from a UniProt/UniParc header.
    Priority: Gene ID (AAEL####-PA) > UniProt Accession > UPI
    """
    header = header.strip()
    print(f"Header: {header}")
    

# Actual function to shorten FASTA headers
def clean_fasta(input_path, output_path, map_path, species_code):
    """
    Process one FASTA file and shorten FASTA headers.
    Parameters:
    - input_path = aegypti_fasta or albopictus_fasta
    - output_path = "name.fasta" --> Name of the cleaned fasta
    - map_path = "name.tsv" --> Name of the mapped proteins file
    - species_code = AAEG or AALB
    """
    input_path = Path(input_path)
    output_path = Path(output_path)
    map_path = Path(map_path)

    print(f"🧹 Processing {input_path.name} --> {output_path.name}")

    if not input_path.exists():
        raise FileNotFoundError(f"Input file not found: {input_path}")

    with open(input_path) as f_in, open(output_path, "w") as f_out, open(
        map_path, "w"
    ) as f_map:

        f_map.write("OriginalHeader\tCleanID\n")  # TSV header

        seq_buffer = ""
        current_header = None

        for line in f_in:
            if line.startswith(">"):
                # Save previous sequence
                if current_header and seq_buffer:
                    f_out.write(seq_buffer + "\n")
                    f_map.write(f"{current_header}\t{clean_id}\n")

                # Process new header
                current_header = line.strip().lstrip(">")
                clean_id = extract_id(current_header, species_code)
                clean_header = f">{species_code}|{clean_id}"

                f_out.write(f"{clean_header}\n")
                seq_buffer = ""
            else:
                seq_buffer += line.strip()

        # Don't forget the last sequence
        if current_header and seq_buffer:
            f_out.write(seq_buffer + "\n")
            f_map.write(f"{current_header}\t{clean_id}\n")

    print(f"✅ Saved cleaned FASTA: {output_path}")
    print(f"✅ Saved ID map: {map_path}")


# Defining main function
def main():
    # ====== CONFIGURATION ========
    # Detect OS automatically because I don't want to change paths
    # each time I change from personal laptop
    # to work computer
    os_name = platform.system()
    print(f"OS detected: {os_name}")

    if os_name == "Darwin":
        base_dir = (
            Path.home()
            / "documents"
            / "01-livs"
            / "20-work"
            / "upch-asistente-investigacion"
            / "miRNA-targets-fa5/cytoscape"
            / "all-clean"
        )
    elif os_name == "Linux":
        base_dir = Path.home() / "livisu" / "cytoscape" / "all-clean"
    else:
        print(f"Unsupported OS: {os_name}")
        sys.exit(1)

    out_dir = base_dir / "orthofinder_input"
    # create the output direct if it doesn't exist
    out_dir.mkdir(exist_ok=True)
    print(f"Successfully created output directory --> {out_dir}")

    # Input files
    aegypti_fasta = base_dir / "Aedes_aegypti.fasta"
    albopictus_fasta = base_dir / "Aedes_albopictus.fasta"

    # Use FASTA formatting function
    clean_fasta(
        input_path=aegypti_fasta,
        output_path=out_dir / "Aaeg_clean.fasta",
        map_path=out_dir / "Aaeg_id_map.tsv",
        species_code="AAEG"
    )
    

# Run the main function only if this is script is run directly in the terminal
# with python
if __name__ == "__main__":
    main()
