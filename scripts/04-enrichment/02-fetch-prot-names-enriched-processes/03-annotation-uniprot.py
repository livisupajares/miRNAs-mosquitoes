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

# Run the script for each `full_expanded` dataframe.

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