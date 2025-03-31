#!/usr/bin/env bash

# How many sequences in total
# grep -c "^>" "$1" (input file)
# Check number of residues
# grep -v '>' aae-1.fasta | wc -c

# USAGE = ./split-all-prot-fasta.sh input_file.fasta

# Check if all required arguments are provided. In this case, -ne should be 1.
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <input_fasta_file>"
    exit 1
fi

# Define input variables
INPUT_FILE="$1"

# Debugging: Print the received argument
echo "Received input file: $INPUT_FILE"

# Ensure the input file exists
if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: File '$INPUT_FILE' not found."
    exit 1
fi

# Call the awk script to split the FASTA file
echo "Processing input file: $INPUT_FILE"
awk -f split-fasta-by-residues.awk "$INPUT_FILE"

# Define the output directory used by the awk script
OUTPUT_DIR="/home/cayetano/livisu/git/miRNAs-mosquitoes/sequences/miRNAtarget_prot_seq/output_dir/"

# Check if output files were created
if [ -d "$OUTPUT_DIR" ]; then
    echo "FASTA file has been split into parts with <= 10,000 residues per file."
    echo "All output files are saved in the '$OUTPUT_DIR' directory."
    ls -l "$OUTPUT_DIR"part*.fasta
else
    echo "Error: Output directory '$OUTPUT_DIR' was not created."
    exit 1
fi

# Verify that all the sequences have been processed
# cd output_dir
# grep -c "^>" /home/cayetano/livisu/git/miRNAs-mosquitoes/sequences/miRNAtarget_prot_seq/output_dir/part*.fasta | awk -F: '{sum += $2} END {print "Total sequences:", sum}'