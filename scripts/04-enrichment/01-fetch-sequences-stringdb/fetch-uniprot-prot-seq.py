# ~~~~~ FETCH UNIPROT PROTEIN SEQUENCES ~~~~~ #
# TODO: Turn the script into a module
# TODO: Add Parallel Processing to make it run faster
# "miRNA" (miRNA targets) can also be replaced for any .txt file inside a
# directory that contains uniprotkb and/or uniparc ids.
# Check the created logs and the terminal output to see if some accession failed.

# Import dependencies
import logging
import os  # for manipulation of files
import platform
import sys
import time
from pathlib import Path

import requests
from tqdm import tqdm  # progress bars

# Configuration
root_dir = None

def choose_base_dir():
    global root_dir

    # Detect OS
    os_name = platform.system()
    print(f"OS detected: {os_name}")

    # Load files
    if os_name == "Darwin":
        root_dir = (
            Path.home()
            / "Documents"
            / "01-livs"
            / "14-programming"
            / "git"
            / "miRNAs-mosquitoes"
        )
    elif os_name == "Linux":
        root_dir = (
            Path.home() 
            / "livisu" 
            / "git" 
            / "miRNAs-mosquitoes" 
        )
    else:
        print(f"Unsupported OS: {os_name}")
        sys.exit(1)

# Let the program detect whether we are in my personal laptop or work computer
choose_base_dir()

# Input directory to read .txt files with Uniprot kb accessions
# input_directory = f"{root_dir}/results/02-enrichment/01-raw-input-output/stringdb/input/per-mirna/aal-miranda-per-mirna"
# input_directory = root_dir / "results" / "02-enrichment" / "01-raw-input-output" / "stringdb" / "input" / "per-mirna" / "aae-common-per-mirna"
# input_directory = root_dir / "results" / "02-enrichment" / "01-raw-input-output" / "stringdb" / "input" /"aae-common-per-mirna"
# input_directory = root_dir / "results" / "02-enrichment" / "01-raw-input-output" / "stringdb" / "input" /"aae-common-all"

input_directory = root_dir / "results" / "02-enrichment" / "05-blast-annotation" / "uniprot_ids_txt"

# Output directory to store the FASTA files
# output_dir = f"{root_dir}/sequences/04-enrichment/00-stringdb-input/per-mirna/aal-miranda-per-mirna-stringdb"
# output_dir = f"{root_dir}/sequences/04-enrichment/00-stringdb-input/aae-common-per-mirna"
# output_dir = f"{root_dir}/sequences/04-enrichment/00-stringdb-input/aae-common-all"

output_dir = root_dir / "sequences" / "05-blast-annotation"

# Add a directory to deposit logs in case an accession can't be fetched
log_directory = os.path.join(output_dir, "logs")
# Base URL for UniProt REST API
base_url = "https://rest.uniprot.org/{database}/{acc}.fasta"

# Create directories if they don't exist
os.makedirs(output_dir, exist_ok=True)
os.makedirs(log_directory, exist_ok=True)


# Setup logger per miRNA
# This logger writes only ERROR+ to file, but shows INFO+ in console
def setup_logger(name, log_file, level=logging.ERROR):
    logger = logging.getLogger(name)
    logger.setLevel(logging.DEBUG)
    if logger.hasHandlers():
        logger.handlers.clear()

    # File handler: only errors
    fh = logging.FileHandler(log_file)
    fh.setLevel(logging.ERROR)
    fh_formatter = logging.Formatter("%(asctime)s | %(message)s", datefmt="%H:%M:%S")
    fh.setFormatter(fh_formatter)
    logger.addHandler(fh)

    # Console handler: info and above
    ch = logging.StreamHandler()
    ch.setLevel(logging.INFO)
    ch_formatter = logging.Formatter("%(levelname)s | %(message)s")
    ch.setFormatter(ch_formatter)
    logger.addHandler(ch)

    return logger


# Detect database type using regex
def get_database(acc):
    if acc.startswith("UPI") and len(acc) == 13:
        return "uniparc"
    else:
        return "uniprotkb"


# Load miRNA names and accessions from input files with deduplication
def load_miRNA_accessions(input_dir):
    miRNA_to_accessions = {}
    for filename in os.listdir(input_dir):
        if filename.endswith(".txt"):
            mirna_name = os.path.splitext(filename)[0]  # Remove .txt extension
            file_path = os.path.join(input_dir, filename)
            with open(file_path, "r") as f:
                accessions = list(
                    {line.strip() for line in f if line.strip()}
                )  # deduplicated
            miRNA_to_accessions[mirna_name] = accessions
    return miRNA_to_accessions


# Map UniProtKB ID to UniParc ID using UniProt's ID Mapping Rest API
def map_to_uniparc(uniprot_id, logger, timeout=15, max_polls=30, poll_delay=2):
    # Define headers to ensure proper content negotiation
    headers = {"Accept": "application/json"}

    try:
        # Submit the ID mapping job
        submit_url = "https://rest.uniprot.org/idmapping/run"
        params = {"from": "UniProtKB_AC-ID", "to": "UniParc", "ids": uniprot_id}

        res = requests.post(
            submit_url,
            params=params,
            headers=headers,  # ← Critical: tells server we want JSON
            timeout=timeout,
        )
        res.raise_for_status()  # Raises HTTPError for 4xx/5xx status codes
        job_id = res.json()["jobId"]

    except requests.exceptions.Timeout:
        logger.error(f"Request to start ID mapping timed out for {uniprot_id}")
        return None
    except requests.exceptions.HTTPError as e:
        logger.error(f"Failed to create job for {uniprot_id}: {e}")
        if e.response.status_code == 400:
            logger.error(f"Check if '{uniprot_id}' is a valid UniProt ID.")
        return None
    except requests.exceptions.RequestException as e:
        logger.error(
            f"Request failed when starting ID mapping job for {uniprot_id}: {e}"
        )
        return None
    except Exception as e:
        logger.error(f"Unexpected error mapping {uniprot_id}: {e}")
        return None

    # Poll for results
    result_url = f"https://rest.uniprot.org/idmapping/results/{job_id}"  # Clean URL

    for i in range(max_polls):
        time.sleep(poll_delay)
        try:
            res = requests.get(result_url, headers=headers, timeout=timeout)
            # Handle 404: job not ready yet
            if res.status_code == 404:
                continue  # Try again
            # Raise for other bad statuses (500, etc.)
            res.raise_for_status()
        except requests.exceptions.Timeout:
            logger.error(f"Poll {i+1}/{max_polls} timed out {uniprot_id}")
            continue
        except requests.exceptions.ConnectionError:
            logger.error(
                f"Connection error during poll {i+1}/{max_polls} for {uniprot_id}"
            )
            continue
        except requests.exceptions.RequestException as e:
            logger.error(
                f"Request failed during poll {i+1}/{max_polls} for {uniprot_id}: {e}"
            )
            continue

        # If we get here, we have a valid 200 response
        try:
            data = res.json()
        except requests.exceptions.JSONDecodeError:
            logger.error(
                f"Invalid JSON received in poll {i+1}/{max_polls} for {uniprot_id}"
            )
            continue

        # Check if we have results
        if "results" in data and len(data["results"]) > 0:
            result_item = data["results"][0]
            to_field = result_item["to"]
            if isinstance(to_field, dict):
                uniparc_id = to_field["id"]
            elif isinstance(to_field, str):
                uniparc_id = to_field
            else:
                logger.error(f"Unknown format for 'to' field: {to_field}")
                return None
            return uniparc_id
        else:
            logger.error(f"No UniParc mapping found for {uniprot_id}")
            return None

    # End of polling loop
    logger.error(f"Max polling attempts ({max_polls}) reached for {uniprot_id}")
    return None


# Function to fetch and save a UniProt sequence
def fetch_and_save_sequence(acc, logger):
    database = get_database(acc)
    url = base_url.format(database=database, acc=acc)
    headers = {"User-Agent": "miRNA-fetcher/1.0 (Python Script)"}
    reason = "Unknown error"

    for attempt in range(3):
        try:
            response = requests.get(
                url, headers=headers, timeout=10, allow_redirects=True
            )
            if response.status_code == 200:
                fasta_content = response.text.strip()
                if fasta_content.startswith(">") and "\n" in fasta_content:
                    return fasta_content, "Success"
                else:
                    reason = "Invalid FASTA content"
            elif response.status_code == 404:
                reason = f"HTTP 404 Not Found ({database})"
            elif response.status_code == 429:
                reason = "Rate limit"
            else:
                reason = f"HTTP {response.status_code}"
            logger.info(f"Attempt {attempt+1}/3: {reason} for {acc}")
            time.sleep(2)
        except Exception as e:
            reason = f"{type(e).__name__}"
            logger.error(f"Attempt {attempt+1}/3: {reason} for {acc}")
            time.sleep(2)

    # Only one fallback attempt
    logger.info(f"--- FAILED: {acc} ---")
    logger.info(f"Attempting to map {acc} to UniParc...")
    uniparc_id = map_to_uniparc(acc, logger)

    if uniparc_id:
        logger.info(f"Mapped {acc} → {uniparc_id}")
        url = base_url.format(database="uniparc", acc=uniparc_id)
        try:
            response = requests.get(url, headers=headers, timeout=10)
            if response.status_code == 200:
                fasta_content = response.text.strip()
                if fasta_content.startswith(">") and "\n" in fasta_content:
                    logger.info(f"SUCCESS: Retrieved from UniParc for {uniparc_id}")
                    return fasta_content, "Success (via UniParc)"
        except Exception as e:
            logger.error(f"Failed retrieving from UniParc: {e}")
    else:
        reason = "UniParc mapping failed"

    logger.error(f"FAILED TO FETCH {acc} AFTER ALL ATTEMPTS\n")
    return None, reason


# Iterate over the dictionary and process each miRNA and its accessions
# Main execution
if __name__ == "__main__":
    # Load accessions dynamically
    miRNA_to_accessions = load_miRNA_accessions(input_directory)

    # To store final list of completely failed accessions per miRNA
    failed_summary = {}

    # Process each miRNA group
    for mirna, accessions in miRNA_to_accessions.items():
        print(f"\nProcessing miRNA: {mirna} ({len(accessions)} accessions)")

        log_file = os.path.join(log_directory, f"log_{mirna}.log")
        logger = setup_logger(f"logger_{mirna}", log_file)

        # Collect all FASTA sequences for the current miRNA
        fasta_sequences = []
        failed_for_mirna = []  # Track accessions that completely failed

        for acc in tqdm(accessions, desc=f"Fetching {mirna}", total=len(accessions)):
            fasta_content, failure_reason = fetch_and_save_sequence(acc, logger)
            if fasta_content:
                fasta_sequences.append(fasta_content)
            else:
                # Only mark as "completely failed" if we tried everything
                failed_for_mirna.append(acc)
            time.sleep(0.25)  # Rate limiting so they don't flag your IP

        # Save all sequences for the current miRNA into one FASTA file
        if fasta_sequences:
            fasta_filename = os.path.join(output_dir, f"{mirna}.fasta")
            with open(fasta_filename, "w") as f:
                f.write(
                    "\n".join(fasta_sequences)
                )  # Combine all sequences into one file
            print(
                f"✅ Saved {len(fasta_sequences)} sequences for {mirna} to {fasta_filename}"
            )
        else:
            print(f"❌ No valid sequences found for {mirna}")
        
        # Save failures for THIS txt file before moving to next
        if failed_for_mirna:
            failed_summary[mirna] = failed_for_mirna

    print("\n✅Script completed successfully.")

    # =================== FINAL SUMMARY ===================
    print("\n" + "=" * 60)
    print("            🚨 FINAL FAILURE SUMMARY 🚨")
    print("=" * 60)

    if not failed_summary:
        print("🎉 All accessions were successfully fetched! No failures.")
    else:
        total_failed = sum(len(acc_list) for acc_list in failed_summary.values())
        print(
            f"❌ {total_failed} accession(s) failed across {len(failed_summary)} miRNA(s):\n"
        )

        for mirna, failed_accs in failed_summary.items():
            print(f"📁 {mirna} ({len(failed_accs)} failure(s)):")
            # Deduplicate and show up to 10, then summarize
            unique_failed = sorted(set(failed_accs))
            for acc in unique_failed[:10]:
                print(f"    • {acc}")
            if len(unique_failed) > 10:
                print(f"    ... and {len(unique_failed) - 10} more")
            print()

        print(f"📄 Full error details are logged in: {log_directory}/")
    print("=" * 60)
    print("✅ Script completed successfully.")
