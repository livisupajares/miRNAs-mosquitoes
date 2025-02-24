from Bio import Entrez, SeqIO

# Set your email address (required by NCBI)
Entrez.email = "livisu.pajares.r@upch.pe"

def fetch_protein_sequences(accession_numbers):
    """Fetch protein sequences from UniProtKB given a list of accession numbers."""
    protein_records = []
    
    for acc in accession_numbers:
        try:
            # Fetch the GenBank record from NCBI using the accession number
            handle = Entrez.efetch(db="protein", id=acc, rettype="gb", retmode="text")
            record = SeqIO.read(handle, "genbank")
            handle.close()
            
            # Append the record to the list of protein records
            protein_records.append(record)
        except Exception as e:
            # Debugging: Print the exception type and message
            print(f"Error fetching {acc}: {e}")
    
    return protein_records

if __name__ == "__main__":
    # Test data
    accessions = ["P12345", "Q67890"]
    fetch_protein_sequences(accessions)