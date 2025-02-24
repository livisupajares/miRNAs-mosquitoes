# ~~~~~ FETCH UNIPROT PROTEIN SEQUENCES ~~~~~ #
# Import dependencies
from Bio import Entrez, SeqIO
import os

# Set your email address (required by NCBI)
Entrez.email = "livisu.pajares.r@upch.pe"