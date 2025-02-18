# Program to convert all T nucleotides into U nucleotides
# Import Biopython and Pandas
from Bio.Seq import Seq
import pandas as pd

# Import database
aal_miRNAs = pd.read_csv("/Users/skinofmyeden/Documents/01-livs/14-programming/git/miRNAs-mosquitoes/sequences/aal-complete/aal-mirna-seq.csv")

# Make function to transcribe miRNA T nucleotide into U
def transcribe_dna_to_rna(miRNA_seq):
    return str(Seq(miRNA_seq).transcribe())

my_seq = Seq('ACTGactgACTG')
my_seq = my_seq.transcribe()
print(my_seq)