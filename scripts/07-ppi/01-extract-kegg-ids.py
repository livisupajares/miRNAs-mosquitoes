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
# Identify rows where kegg_id is empty
# Create a new column mapped_id = stripped identifier (remove 7159., 7160.)
# For rows with empty kegg_id, map mapped_id → KEGG using UniProt's REST API
# Fill in the kegg_id column with the result
#
# Step 3: Log every failure, retry, success
# Wrap in the same logger system created for fetch-uniport-prot-seq.py

import logging
import platform
import sys
import time
from pathlib import Path

import pandas as pd
import requests
from tqdm import tqdm

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

# Map taxon ID to KEGG organism code
TAXON_TO_KEGG_ORG = {"7159": "aag", "7160": "aalb"}  # Aedes aegypti  # Aedes albopictus

# Setup logging directory
log_dir = base_dir / "logs_kegg_mapping"
log_dir.mkdir(exist_ok=True)


def setup_logger(name, log_file):
    """Setup logger: INFO+ to console, ERROR+ to file"""
    logger = logging.getLogger(name)
    logger.setLevel(logging.DEBUG)
    if logger.hasHandlers():
        logger.handlers.clear()

    # File handler (errors only)
    fh = logging.FileHandler(log_file)
    fh.setLevel(logging.ERROR)
    fh_formatter = logging.Formatter("%(asctime)s | %(message)s", datefmt="%H:%M:%S")
    fh.setFormatter(fh_formatter)
    logger.addHandler(fh)

    # Console handler (info+)
    ch = logging.StreamHandler()
    ch.setLevel(logging.INFO)
    ch_formatter = logging.Formatter("%(levelname)s | %(message)s")
    ch.setFormatter(ch_formatter)
    logger.addHandler(ch)

    return logger


def extract_kegg_id(annotation):
    if pd.isna(annotation):
        return None
    parts = str(annotation).split(",")
    for part in reversed(parts):  # Check from end
        part = part.strip()
        if part.startswith("aag:") or part.startswith("aalb:"):
            return part
    return None


def strip_taxon_prefix(identifier):
    """Convert '7159.Q0C7A8' → 'Q0C7A8', '7160.A0A182H615' → 'A0A182H615'"""
    if pd.isna(identifier):
        return None
    parts = str(identifier).split(".", 1)
    if len(parts) == 2:
        return parts[1]
    return identifier


def map_uniprot_to_kegg_via_idmapping(uniprot_id, taxon_id, logger):
    """Use UniProt ID Mapping API to map UniProt → KEGG"""
    if not uniprot_id or pd.isna(uniprot_id):
        logger.error("Empty or NaN UniProt ID")
        return None

    org_code = TAXON_TO_KEGG_ORG.get(str(taxon_id), None)
    if not org_code:
        logger.error(f"[{uniprot_id}]Unknown taxon ID: {taxon_id}")
        return None

    # Step 1: Submit mapping job
    submit_url = "https://rest.uniprot.org/idmapping/run"
    params = {"from": "UniProtKB_AC-ID", "to": "KEGG", "ids": uniprot_id}

    for attempt in range(3):
        try:
            response = requests.post(submit_url, data=params, timeout=10)
            if response.status_code == 429:
                logger.info(f"Rate limited (attempt {attempt+1}) — waiting 3s")
                time.sleep(3)
                continue
            elif response.status_code != 200:
                logger.error(
                    f"Submit failed: HTTP {response.status_code} (attempt {attempt+1})"
                )
                time.sleep(1)
                continue

            job_data = response.json()
            job_id = job_data.get("jobId")
            if not job_id:
                logger.error("No jobId returned from submit")
                return None

            break  # Success — exit retry loop
        except Exception as e:
            logger.error(f"Submit error (attempt {attempt+1}): {e}")
            time.sleep(2)
    else:
        logger.error("Max submit attempts exceeded")
        return None

    # Step 2: Poll for results
    result_url = f"https://rest.uniprot.org/idmapping/results/{job_id}"

    for poll_attempt in range(30):  # Max 30 polls
        time.sleep(1)  # Wait 1 second between polls
        try:
            response = requests.get(result_url, timeout=10)
            if response.status_code == 404:
                continue  # Job not ready yet
            elif response.status_code != 200:
                logger.error(f"Poll failed: HTTP {response.status_code}")
                break

            data = response.json()
            results = data.get("results", [])

            if len(results) > 0:
                first_result = results[0]
                to_value = first_result.get("to", "")
                if isinstance(to_value, str) and to_value.startswith(org_code + ":"):
                    return to_value
                else:
                    logger.error(
                        f"[{uniprot_id}] Result doesn't match organism: {to_value}"
                    )
                    return None
            else:
                logger.error(f"[{uniprot_id}] No results found in mapping response")
                return None
        except Exception as e:
            logger.error(f"[{uniprot_id}] Poll error: {e}")
            time.sleep(1)

    logger.error("Max polling attempts reached — job may have failed")
    return None


# Process each file
failed_summary = {}

# Process each file
for input_file in input_files:
    species = input_file.stem.split("_")[0]  # "aae" or "aal"
    print(f"Processing: {input_file.name}")

    # Setup logger for this species
    log_file = log_dir / f"log_{species}_kegg_mapping.log"
    logger = setup_logger(f"logger_{species}", log_file)

    # Read TSV
    df = pd.read_csv(input_file, sep="\t")

    # Step 1: Extract KEGG from annotation (using correct column name
    df["kegg_id"] = df["other_names_and_aliases"].apply(extract_kegg_id)

    # Step 2: Create mapped_id (stripped identifier)
    df["mapped_id"] = df["identifier"].apply(strip_taxon_prefix)
    df["taxon_id"] = df["identifier"].str.split(".", n=1).str[0]

    # Step 3: Fill missing kegg_id by mapping via UniProt ID Mapping API
    missing = df["kegg_id"].isna() & df["mapped_id"].notna()
    logger.info(
        f"🧬 Found {missing.sum()} proteins missing KEGG ID — attempting to map via UniProt ID Mapping API..."
    )

    count_mapped = 0
    failed_ids = []

    # Use tqdm for progress bar
    for idx in tqdm(df[missing].index, desc=f"Mapping {species}", total=missing.sum()):
        uniprot_id = df.at[idx, "mapped_id"]
        taxon_id = df.at[idx, "taxon_id"]
        kegg = map_uniprot_to_kegg_via_idmapping(uniprot_id, taxon_id, logger)
        if kegg:
            df.at[idx, "kegg_id"] = kegg
            count_mapped += 1
        else:
            failed_ids.append(uniprot_id)
        time.sleep(0.2)  # Be kind to UniProt API

    logger.info(f"✅ Mapped {count_mapped} additional proteins to KEGG")
    if failed_ids:
        failed_summary[species] = failed_ids

    # Create output filename: e.g., "aae_with_kegg.tsv"
    output_file = input_file.with_name(input_file.stem + "_with_kegg.tsv")

    # Save
    df.to_csv(output_file, sep="\t", index=False)
    logger.info(f"💾 Saved: {output_file}\n")

# =================== FINAL SUMMARY ===================
print("\n" + "=" * 60)
print("            🚨 FINAL FAILURE SUMMARY 🚨")
print("=" * 60)

if not failed_summary:
    print("🎉 All missing KEGG IDs were successfully mapped!")
else:
    total_failed = sum(len(id_list) for id_list in failed_summary.values())
    print(
        f"❌ {total_failed} UniProt ID(s) failed to map to KEGG across {len(failed_summary)} species:\n"
    )

    for species, failed_ids in failed_summary.items():
        unique_failed = sorted(set(failed_ids))
        print(f"📁 {species.upper()} ({len(unique_failed)} failure(s)):")
        for acc in unique_failed[:10]:
            print(f"    • {acc}")
        if len(unique_failed) > 10:
            print(f"    ... and {len(unique_failed) - 10} more")
        print()

    print(f"📄 Full error logs: {log_dir}/")
print("=" * 60)
print("✅ Script completed successfully.")
