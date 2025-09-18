# ~~~~~ EXTRACT KEGG IDS ~~~~~ #
# This script will take as input the Annotation.tsv files
# from STRINGDB and take the other_names_and_aliases column
# to extract the KEGG_ID with a pattern: aag: and aalb: and
# append a new column called KEGG_ID to the same file

from pathlib import Path

import pandas as pd

# Load files
base_dir = Path.home() / "livisu" / "git" / "miRNAs-mosquitoes" / "results" / "03-ppi"
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
