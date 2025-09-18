# ~~~~~ EXTRACT & MAP KEGG IDS WITH LOGGING ~~~~~ #
#
# Step 1: Extract KEGG from annotation
# This script will take as input the Annotation.tsv files
# from STRINGDB and take the other_names_and_aliases column
# to identify and extract KEGG_IDs based on a pattern
# where the ids start with a species identificator (aag and aalb).
# Append a new column called KEGG_ID to the same file
#
# Step 2: For missing KEGG, map identifier → UniProt → KEGG
# TODO: Identify rows where kegg_id is empty
# TODO: Create a new column mapped_id = stripped identifier (remove 7159., 7160.)
# TODO: For rows with empty kegg_id, map mapped_id → KEGG using UniProt's REST API
# TODO: Fill in the kegg_id column with the result
#
# Step 3: Log every failure, retry, success
# TODO: Wrap in the same logger system created for fetch-uniport-prot-seq.py

import platform
import sys
from pathlib import Path

import pandas as pd

# Detect OS
os_name = platform.system()
print(f"OS detected: {os_name}")

# Load files
if os_name == "Darwin":
    base_dir = (
        Path.home()
        / "Documents"
        / "01-livs"
        / "14-programming"
        / "git"
        / "miRNAs-mosquitoes"
        / "results"
        / "03-ppi"
    )
elif os_name == "Linux":
    base_dir = (
        Path.home() / "livisu" / "git" / "miRNAs-mosquitoes" / "results" / "03-ppi"
    )
else:
    print(f"Unsupported OS: {os_name}")
    sys.exit(1)

input_files = [
    base_dir / "aae_string_protein_annotations.tsv",
    base_dir / "aal_string_protein_annotations.tsv",
]


def extract_kegg_id(annotation):
    if pd.isna(annotation):
        return None
    parts = str(annotation).split(",")
    for part in reversed(parts):  # Check from end
        part = part.strip()
        if part.startswith("aag:") or part.startswith("aalb:"):
            return part
    return None


# Process each file
for input_file in input_files:
    print(f"Processing: {input_file}")

    # Read TSV
    df = pd.read_csv(input_file, sep="\t")

    # Extract KEGG ID
    df["kegg_id"] = df["other_names_and_aliases"].apply(extract_kegg_id)

    # Create output filename: e.g., "aae_with_kegg.tsv"
    output_file = input_file.with_name(input_file.stem + "_with_kegg.tsv")

    # Save
    df.to_csv(output_file, sep="\t", index=False)

    print(f"✅ Saved: {output_file}\n")

print("🎉 All files processed!")
