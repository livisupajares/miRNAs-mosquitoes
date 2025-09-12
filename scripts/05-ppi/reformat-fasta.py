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

# Import Packages
from pathlib import Path
import platform

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
        base_dir = (
            Path.home() 
            / "livisu" 
            / "cytoscape" 
            / "all-clean"
        )
    out_dir = base_dir / "orthofinder_input"
    # create the output direct if it doesn't exist
    out_dir.mkdir(exist_ok=True)
    print(f"Successfully created output directory --> {out_dir}")
    
    # Input files
    aegypti_fasta = base_dir / "Aedes_aegypti.fasta"
    print(f"aae fasta path --> {aegypti_fasta}")
    albopictus_fasta = base_dir / "Aedes_albopictus.fasta"
    print(f"aal fasta path --> {albopictus_fasta}")

# Run the main function only if this is script is run directly in the terminal
# with python
if __name__ == "__main__":
    main()
