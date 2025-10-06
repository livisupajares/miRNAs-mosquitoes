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

import json
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