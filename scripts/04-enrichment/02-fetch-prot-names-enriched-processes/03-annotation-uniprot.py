# ~~~~~~ FETCH UNIPROT ACCESSION DATA ~~~~~~~~~~
# This script will get the full_expanded dataframes from 02-prots-enriched-process
# and for the `matching_proteins_id_network` variable (Uniprot IDs) will be used
# as input for UniProtKB GET API. Wrap the script in a logger and log failues.
# This script will get the following data and append results in the original
# `full_expanded` dataframes, where each data will be added in their own column:

# protein_name --> protein_name column
# gene_primary --> gene_primary column
# cc_function --> cc_function column
# go_p --> go_p column (GO Biological Process)
# go_f --> go_f column (GO Molecular Function)

# Detect if an entry has been moved to UniParc. If that's the case, then add 
# "NA" to all the other columns (protein_name, gene_primary, cc_function, go_p, 
# go_f). Then, log these IDs as failures in logs and print in console a summary 
# of the run.

import logging
import platform
import sys
import time
from pathlib import Path

import pandas as pd
import requests
from tqdm import tqdm

base_dir = None

def choose_base_dir():
    global base_dir

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
            / "02-enrichment"
            / "04-enrich-full-anotation"
        )
    elif os_name == "Linux":
        base_dir = (
            Path.home() 
            / "livisu" 
            / "git" 
            / "miRNAs-mosquitoes" 
            / "results" 
            / "02-enrichment"
            / "04-enrich-full-anotation"
        )
    else:
        print(f"Unsupported OS: {os_name}")
        sys.exit(1)

# Let the program detect whether we are in my personal laptop or work computer
choose_base_dir()

# Input files
input_files = [
    base_dir / "full-expanded-all-down-stringdb.csv",
    base_dir / "full-expanded-all-stringdb.csv",
    base_dir / "full-expanded-per-mirna-down-stringdb.csv",
    base_dir / "full-expanded-per-mirna-stringdb.csv"
]

# Setup logging directory
log_dir = base_dir / "logs_annotation"
log_dir.mkdir(exist_ok=True)

# Setup an output directory
out_dir = base_dir / "output_annotation"
out_dir.mkdir(exist_ok=True)

# Define logger
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

def get_uniprot_col_index(filename: str) -> int:
    """Determine column index for matching_proteins_id_network"""
    if "per-mirna" in filename:
        return 9  # 10th column (0-based index 9)
    else:
        return 8  # 9th column (0-based index 8)

def parse_uniprot_response(data: dict) -> dict:
    result = {
        "protein_name": "NA",
        "gene_primary": "NA",
        "cc_function": "NA",
        "go_p": "NA",
        "go_f": "NA"
    }

    # === protein_name ===
    try:
        pdesc = data.get("proteinDescription", {})
        rec_name = pdesc.get("recommendedName", {})
        full_name = rec_name.get("fullName", {}).get("value")
        if not full_name:
            alt_names = pdesc.get("alternativeNames", [])
            if alt_names:
                full_name = alt_names[0].get("fullName", {}).get("value")
        result["protein_name"] = full_name if full_name else "NA"
    except Exception:
        pass

    # === gene_primary ===
    try:
        genes = data.get("genes", [])
        if genes and "geneName" in genes[0]:
            gene_val = genes[0]["geneName"].get("value")
            result["gene_primary"] = gene_val if gene_val else "NA"
    except Exception:
        pass

    # === cc_function ===
    try:
        comments = data.get("comments", [])
        func_comment = next((c for c in comments if c.get("commentType") == "FUNCTION"), None)
        if func_comment and "texts" in func_comment and func_comment["texts"]:
            func_text = func_comment["texts"][0].get("value")
            result["cc_function"] = func_text if func_text else "NA"
    except Exception:
        pass

    # === GO terms (P and F) ===
    try:
        xrefs = data.get("uniProtKBCrossReferences", [])
        go_refs = [x for x in xrefs if x.get("database") == "GO"]
        p_terms = []
        f_terms = []
        for ref in go_refs:
            props = ref.get("properties", [])
            for prop in props:
                if prop.get("key") == "GoTerm":
                    term = prop.get("value", "")
                    if term.startswith("P:"):
                        p_terms.append(term[2:])
                    elif term.startswith("F:"):
                        f_terms.append(term[2:])
        result["go_p"] = "; ".join(p_terms) if p_terms else "NA"
        result["go_f"] = "; ".join(f_terms) if f_terms else "NA"
    except Exception:
        pass

    return result

def fetch_uniprot_entry(uniprot_id: str, logger, max_retries=3):
    url = f"https://rest.uniprot.org/uniprotkb/{uniprot_id}"
    headers = {
        "accept": "application/json",
        "User-Agent": "miRNA-annotation-fetcher/1.0 (Python Script)"
    }
    params = {
        "fields": "protein_name,gene_primary,cc_function,go_p,go_f"
    }

    for attempt in range(max_retries):
        try:
            response = requests.get(url, headers=headers, params=params, timeout=10)
            if response.status_code == 200:
                data = response.json()

                # Check for inactive entry
                if data.get("entryType") == "Inactive":
                    primary_acc = data.get("primaryAccession", uniprot_id)
                    uniparc_id = data.get("extraAttributes", {}).get("uniParcId", "N/A")
                    logger.error(
                        f"Inactive entry: {primary_acc} → moved to UniParc {uniparc_id}"
                    )
                    return None  # Treat as failure

                if "primaryAccession" in data:
                    return parse_uniprot_response(data)
                else:
                    logger.error(f"No primaryAccession in response for {uniprot_id}")
                    return None

            elif response.status_code == 404:
                logger.info(f"404 Not Found: {uniprot_id} → likely moved to UniParc")
                return None

            elif response.status_code == 429:
                wait = 2 ** (attempt + 1)
                logger.info(f"Rate limited for {uniprot_id}, waiting {wait}s")
                time.sleep(wait)
                continue

            else:
                logger.error(f"HTTP {response.status_code} for {uniprot_id}")
                return None

        except Exception as e:
            logger.error(f"Error fetching {uniprot_id} (attempt {attempt+1}): {e}")

        time.sleep(1)

    return None

def process_dataframe(df: pd.DataFrame, filepath: Path, logger):
    filename = filepath.name
    uniprot_col_idx = get_uniprot_col_index(filename)

    cols = ["protein_name", "gene_primary", "cc_function", "go_p", "go_f"]
    # ✅ Initialize new columns only if they don't exist
    for col in cols:
        if col not in df.columns:
            df[col] = "NA"

    if df.empty or uniprot_col_idx >= df.shape[1]:
        logger.warning(f"Invalid column index {uniprot_col_idx} for {filename}")
        return df, []

    uniprot_series = df.iloc[:, uniprot_col_idx].dropna()
    uniprot_ids = uniprot_series.unique().tolist()
    if not uniprot_ids:
        logger.info(f"No UniProt IDs in {filename}")
        return df, []

    logger.info(f"Processing {len(uniprot_ids)} UniProt IDs from {filename}")

    cache = {}
    failed = []

    for uid in tqdm(uniprot_ids, desc=f"Annotating {filename}", total=len(uniprot_ids)):
        if uid in cache:
            continue
        ann = fetch_uniprot_entry(uid, logger)
        if ann is None:
            ann = {col: "NA" for col in cols}
            failed.append(uid)
        cache[uid] = ann
        time.sleep(0.25)

    # Apply cached annotations (handles duplicates automatically)
    for idx in df.index:
        uid = df.iat[idx, uniprot_col_idx]
        if pd.isna(uid) or uid == "":
            continue
        ann = cache.get(uid, {col: "NA" for col in cols})
        for col in cols:
            df.at[idx, col] = ann[col]

    return df, failed

def main():
    global_summary = {}

    for input_file in input_files:
        if not input_file.exists():
            print(f"⚠️  Skipping missing file: {input_file.name}")
            continue

        print(f"\n📄 Processing: {input_file.name}")
        logger = setup_logger(f"logger_{input_file.stem}", log_dir / f"log_{input_file.stem}.log")

        try:
            # ✅ READ WITH HEADERS
            df = pd.read_csv(input_file, dtype=str, keep_default_na=False)
        except Exception as e:
            logger.error(f"Failed to read {input_file}: {e}")
            continue

        annotated_df, failed_ids = process_dataframe(df, input_file, logger)
        global_summary[input_file.name] = failed_ids

        output_path = out_dir / f"{input_file.stem}_annotated.csv"
        # ✅ WRITE WITH HEADERS
        annotated_df.to_csv(output_path, index=False, header=True)
        logger.info(f"✅ Saved to {output_path}")

    # Final summary
    print("\n" + "=" * 60)
    print("            🚨 FINAL FAILURE SUMMARY 🚨")
    print("=" * 60)

    total_failures = sum(len(ids) for ids in global_summary.values())
    if total_failures == 0:
        print("🎉 All entries successfully annotated!")
    else:
        print(f"❌ {total_failures} UniProt ID(s) failed across {len(global_summary)} file(s):\n")
        for fname, failed_list in global_summary.items():
            if failed_list:
                unique_failed = sorted(set(failed_list))
                print(f"📁 {fname} ({len(unique_failed)} failure(s)):")
                for uid in unique_failed[:10]:
                    print(f"    • {uid}")
                if len(unique_failed) > 10:
                    print(f"    ... and {len(unique_failed) - 10} more")
                print()
        print(f"📄 Logs: {log_dir}/")

    print("=" * 60)
    print("✅ Annotation complete.")


if __name__ == "__main__":
    main()