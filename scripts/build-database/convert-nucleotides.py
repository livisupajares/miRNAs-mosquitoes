# Program to convert all T nucleotides into U nucleotides
from Bio.Seq import Seq
my_seq = Seq('ACTGactgACTG')
my_seq = my_seq.transcribe()
print(my_seq)