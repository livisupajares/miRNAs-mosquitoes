# ~~~~~ FETCH UNIPROT PROTEIN SEQUENCES ~~~~~ #
# TODO: Turn the script into a module
# TODO: Add Parallel Processing to make it run faster
# "miRNA" (miRNA targets) can also be replaced for any .txt file inside a
# directory that contains uniprotkb and/or uniparc ids.
# Check the created logs and the terminal output to see if some accession failed.

# Import dependencies
import os  # for manipulation of files
import time

import requests
from tqdm import tqdm  # progress bars

# Configuration
# TODO make a root directory picker bc I'm too lazy to change root_dir
# Add root directory
root_dir = "/Users/skinofmyeden/Documents/01-livs/14-programming/git/miRNAs-mosquitoes"
# Input directory to read .txt files with Uniprot kb accessions
input_directory = f"{root_dir}/results/02-enrichment/01-raw-input-output/shinygo/input/per-mirna/aal-miranda-per-mirna-shinygo"
# Output directory to store the FASTA files
output_dir = f"{root_dir}/sequences/04-enrichment/00-stringdb-input/per-mirna/aal-miranda-per-mirna-stringdb"
# Add a directory to deposit logs in case an accession can't be fetched
log_directory = os.path.join(output_dir, "logs")
# Base URL for UniProt REST API
base_url = "https://rest.uniprot.org/{database}/{acc}.fasta"

# Create directories if they don't exist
os.makedirs(output_dir, exist_ok=True)
os.makedirs(log_directory, exist_ok=True)

# Test write to confirm logs are working
test_log = os.path.join(log_directory, ".test_write.txt")
with open(test_log, "w") as f:
    f.write("Test successful write\n")


# Detect database type using regex
def get_database(acc):
    if acc.startswith("UPI") and len(acc) == 13:
        return "uniparc"
    else:
        return "uniprotkb"


# Load miRNA names and accessions from input files
def load_miRNA_accessions(input_dir):
    miRNA_to_accessions = {}
    for filename in os.listdir(input_dir):
        if filename.endswith(".txt"):
            mirna_name = os.path.splitext(filename)[0]  # Remove .txt extension
            file_path = os.path.join(input_dir, filename)
            with open(file_path, "r") as f:
                accessions = [line.strip() for line in f if line.strip()]
            miRNA_to_accessions[mirna_name] = accessions
    return miRNA_to_accessions


# Map UniProtKB ID to UniParc ID using UniProt's ID Mapping Rest API
def map_to_uniparc(uniprot_id, timeout=15, max_polls=30, poll_delay=2):
    print(f"[INFO] Mapping {uniprot_id} to UniParc...")

    # Define headers to ensure proper content negotiation
    headers = {"Accept": "application/json"}

    try:
        # Submit the ID mapping job
        submit_url = "https://rest.uniprot.org/idmapping/run"  # No trailing spaces!
        params = {"from": "UniProtKB_AC-ID", "to": "UniParc", "ids": uniprot_id}

        res = requests.post(
            submit_url,
            params=params,
            headers=headers,  # ← Critical: tells server we want JSON
            timeout=timeout,
        )
        res.raise_for_status()  # Raises HTTPError for 4xx/5xx status codes
        job_id = res.json()["jobId"]
        print(f"[SUCCESS] ID mapping job created: {job_id}")

        # Poll for results
        result_url = f"https://rest.uniprot.org/idmapping/results/{job_id}"  # Clean URL
        print(f"[POLLING] Checking results at: {result_url}")

        for i in range(max_polls):
            time.sleep(poll_delay)

            try:
                res = requests.get(result_url, headers=headers, timeout=timeout)
                print(
                    f"[DEBUG] Status: {res.status_code}, Content-Type: {res.headers.get('Content-Type')}"
                )
                print(f"[DEBUG] Raw response: {res.text[:200]}")  # First 200 chars

                # Handle 404: job not ready yet
                if res.status_code == 404:
                    print(f"[PENDING] Job not ready (404) - Attempt {i+1}/{max_polls}")
                    continue  # Try again

                # Raise for other bad statuses (500, etc.)
                res.raise_for_status()

            except requests.exceptions.Timeout:
                print(f"[TIMEOUT] Poll {i+1}/{max_polls} timed out")
                continue
            except requests.exceptions.ConnectionError:
                print(f"[CONNECTION ERROR] Failed to connect during poll {i+1}")
                continue
            except requests.exceptions.RequestException as e:
                print(f"[ERROR] Request failed during poll {i+1}: {e}")
                continue

            # If we get here, we have a valid 200 response
            try:
                data = res.json()
                data = res.json()
                print(f"[DEBUG] Type of data: {type(data)}")
                print(f"[DEBUG] Data: {data}")
            except requests.exceptions.JSONDecodeError:
                print(f"[ERROR] Invalid JSON received in poll {i+1}")
                continue

            result_item = data["results"][0]
            print(f"[DEBUG] result_item: {result_item}, type: {type(result_item)}")

            to_field = result_item["to"]
            print(f"[DEBUG] result_item['to']: {to_field}, type: {type(to_field)}")

            # Check if we have results
            if "results" in data and len(data["results"]) > 0:
                result_item = data["results"][0]
                # Extract 'to' field — it could be a string or dict (backward compatibility)
                to_field = result_item["to"]

                if isinstance(to_field, dict):
                    uniparc_id = to_field["id"]
                elif isinstance(to_field, str):
                    uniparc_id = to_field
                else:
                    print(f"[ERROR] Unknown format for 'to' field: {to_field}")
                    return None

                print(f"[SUCCESS] Mapped {uniprot_id} → {uniparc_id}")
                return uniparc_id
            else:
                print(f"[NOTFOUND] No UniParc mapping found for {uniprot_id}")
                return None

        # End of polling loop
        print(f"[FAIL] Max polling attempts ({max_polls}) reached for {uniprot_id}")
        return None

    except KeyError:
        print(f"[ERROR] Unexpected response format: missing 'jobId' for {uniprot_id}")
    except requests.exceptions.Timeout:
        print(f"[TIMEOUT] Request to start ID mapping timed out for {uniprot_id}")
    except requests.exceptions.HTTPError as e:
        print(f"[HTTP ERROR] Failed to create job for {uniprot_id}: {e}")
        if e.response.status_code == 400:
            print(f"[TIP] Check if '{uniprot_id}' is a valid UniProt ID.")
    except requests.exceptions.RequestException as e:
        print(f"[ERROR] Request failed when starting job for {uniprot_id}: {e}")
    except Exception as e:
        print(f"[EXCEPTION] Unexpected error mapping {uniprot_id}: {e}")

    return None


# Function to fetch and save a UniProt sequence
def fetch_and_save_sequence(acc, mirna_name):
    database = get_database(acc)
    url = base_url.format(database=database, acc=acc)

    # Add user agents so you don't get flagged by the UniProt API
    headers = {"User-Agent": "miRNA-fetcher/1.0 (Python Script)"}

    for attempt in range(3):  # Retry up to 3 times
        try:
            response = requests.get(
                url, headers=headers, timeout=10, allow_redirects=True
            )
            if response.status_code == 200:
                fasta_content = response.text.strip()
                # Check if the response looks like a FASTA sequence
                if fasta_content.startswith(">") and "\n" in fasta_content:
                    return fasta_content
                else:
                    print(f"[{attempt+1}/3] Invalid FASTA content for {acc}")
            elif response.status_code in [429, 503]:
                wait_time = 2**attempt
                print(f"[RATE LIMIT] Waiting {wait_time} seconds ...")
                time.sleep(wait_time)
            else:
                print(
                    f"[{attempt+1}/3] Error fetching {acc}: HTTP {response.status_code}"
                )
                time.sleep(2)
        except requests.exceptions.RequestException as e:
            print(f"[{attempt+1}/3] Network error for {acc}: {str(e)}")
            time.sleep(2)

    # If all retries fail, try mapping to UniParc
    print(f"[INFO] Attempting to map {acc} to UniParc...")
    uniparc_id = map_to_uniparc(acc)
    if uniparc_id:
        print(f"[INFO] Mapped to UniParc ID: {uniparc_id}")
        acc = uniparc_id
        database = "uniparc"
        url = base_url.format(database=database, acc=acc)
        # Try one last time with the new ID
        try:
            response = requests.get(url, headers=headers, timeout=10)
            if response.status_code == 200:
                fasta_content = response.text.strip()
                if fasta_content.startswith(">") and "\n" in fasta_content:
                    print(f"[SUCCESS] Retrieved sequence from UniParc for {acc}")
                    return fasta_content
        except Exception as e:
            print(f"[ERROR] Failed retrieving from UniParc for {acc}: {e}")

    # Log failure after all attempts
    error_message = f"Error fetching {acc} from {database} after 3 attempts"
    # Log the error to the log file
    log_file = os.path.join(log_directory, f"log_{mirna_name}.log")
    # Append in the log file
    with open(log_file, "a") as log:
        log.write(f"{error_message}\n")
        log.flush()
    return None


# Iterate over the dictionary and process each miRNA and its accessions
# Main execution
if __name__ == "__main__":
    # Load accessions dynamically
    miRNA_to_accessions = load_miRNA_accessions(input_directory)

    # Process each miRNA group
    for mirna, accessions in miRNA_to_accessions.items():
        print(f"\nProcessing miRNA: {mirna} ({len(accessions)} accessions)")

        # Collect all FASTA sequences for the current miRNA
        fasta_sequences = []
        for acc in tqdm(accessions, desc=f"Fetching {mirna}", total=len(accessions)):
            fasta_content = fetch_and_save_sequence(acc, mirna)
            if fasta_content:
                fasta_sequences.append(fasta_content)
            time.sleep(0.25)  # Rate limiting so they don't flag your IP

        # Save all sequences for the current miRNA into one FASTA file
        if fasta_sequences:
            fasta_filename = os.path.join(output_dir, f"{mirna}.fasta")
            with open(fasta_filename, "w") as f:
                f.write(
                    "\n".join(fasta_sequences)
                )  # Combine all sequences into one file
            print(
                f"Saved {len(fasta_sequences)} sequences for {mirna} to {fasta_filename}"
            )
        else:
            print(f"No valid sequences found for {mirna}")
    print("\nScript completed successfully.")

    # Print summary of failed accessions
    print("\n[SUMMARY] Checking logs...")
    log_files = [
        f
        for f in os.listdir(log_directory)
        if f.startswith("log_") and f.endswith(".log")
    ]

    if not log_files:
        print("✅ No failed accessions found. All sequences were fetched successfully!")
    else:
        for filename in log_files:
            log_path = os.path.join(log_directory, filename)
            with open(log_path, "r") as f:
                lines = f.readlines()
            print(f"\n❌ Failed accessions in {filename} ({len(lines)} failures):")
            for line in lines[:10]:  # Show first 10 errors
                print("  " + line.strip())
            if len(lines) > 10:
                print(f"  ...{len(lines)-10} more errors")
